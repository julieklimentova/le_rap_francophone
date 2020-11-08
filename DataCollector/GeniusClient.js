import axios from 'axios';
import cheerio from 'cheerio';
import LanguageDetect from 'languagedetect';
import he from 'he';
import fs from 'fs';

const accessToken = 'eo5fbsDYIEv5TIgYfTVdLevK2pjKtRDk7Nej7V1gYhpx_eNvlHLji22xvdDskpAl';
const headers = {
    'Authorization': `Bearer ${accessToken}`
}

export class GeniusClient {
    constructor(baseUrl, header) {
        this._baseUrl = baseUrl;
    }

    getArtistId(artist) {
        const encodedArtist = encodeURI(artist);
        const searchQuery = `/search?q=${encodedArtist}`;
        return axios.get(`${this._baseUrl}${searchQuery}`, {timeout: 200000, headers})
            .then(response => {
                const hits = response.data.response.hits;
                // TODO: Possibly come up with a better filtering strategy and put into helpers/ as a method
                const artistsSongs = hits.filter(song => {
                    const geniusName = song.result.primary_artist.name.toLowerCase().trim();
                    const wikiName = artist.toLowerCase();
                    let isArtist = geniusName.includes(wikiName) ? true : false;
                    if (!isArtist) {
                        isArtist = wikiName.includes(geniusName) ? true : false;
                    }
                    const false_exceptions = ['luni', 'nubi', 'gambi', 'koma', 'sheek'];
                    const true_exceptions = [
                        'Akhenaton',
                        'hamed daye',
                        `heuss l'enfoiré`,
                        'joeystarr',
                        `jok'air`,
                        `kalash l'afro`,
                        `mc jean gab'1`,
                        'neg lyrical',
                        'némir',
                        `rim'k`,
                        `rockin' squat`,
                        `sat l'artificier`,
                        `l'animalerie`,
                        `l'armée des 12`,
                        `l'atelier`,
                        'bigflo et oli',
                        'djadja et dinaz',
                        `l'entourage`,
                        'less du neuf',
                        `diam's`,
                        `'t hof van commerce`,
                        `l'skadrille`,
                        `sexion d'assaut`,
                        `nèg' marrons`,
                        `mo'vez lang`,
                        `mafia k'1 fry`,
                        `l'algérino`,
                        // for IAM
                        `shurik'n`,
                        `d' de kabal`,
                        'bassem braiki',
                        `l'afro`,
                        `bassem braïki`
                    ];
                    if (false_exceptions.includes(wikiName)) {
                        isArtist = false;
                    }
                    if (true_exceptions.includes(wikiName)) {
                        isArtist = true;
                    }
                    return isArtist;
                });
                let artistId = '';
                let artistName = '';
                let wikiName = artist;
                if (artistsSongs.length > 0) {
                    artistId = artistsSongs[0].result.primary_artist.id ? artistsSongs[0].result.primary_artist.id : '';
                    artistName = artistsSongs[0].result.primary_artist.name ? artistsSongs[0].result.primary_artist.name : '';
                } else {
                    console.log(`GeniusClient: ERROR: Cannot find artist id for ${artist}`);
                }
                return {artistId, artistName, wikiName};
            })
            .catch(e => {
                    console.log(e)
                return null;
                }
            );
    }

    async getSongs(getSongsArtistInfo) {
        const query = `/artists/${getSongsArtistInfo.artistId}/songs?access_token=${accessToken}`;
        const songs = [];
        await axios.get(`${this._baseUrl}${query}`, {timeout: 200000})
            .then(response => {
                if (response.data) {
                    for (const song of response.data.response.songs) {
                        const songObject = {
                            title: song.full_title,
                            songId: song.id,
                            url: song.url
                        };
                        songs.push(songObject);
                    }
                } // else nothing
            }).catch(e => {
                console.log(`GeniusClient.getSongs: Error when retrieving songs per artist: ${e.message}`);
            });
        return songs;
    }

    parseSongHTML(htmlText, fileName) {
        let $ = cheerio.load(htmlText);
        let lyrics = $('.lyrics').text();
        let dataUnits = $('.metadata_unit--table_row').text();
        if (lyrics) {
            return this.getOutput(lyrics, dataUnits, fileName, htmlText);
        } else {
            lyrics = $('div[initial-content-for=lyrics]').text();
            if (lyrics) {
                return this.getOutput(lyrics, dataUnits, fileName, htmlText);
            } else {
                const lyricsArray = [];
                    $("[class*='Lyrics__Container']").each(function(i) {
                    lyricsArray[i] = $(this).html();
                    });
                    // clean up html tags
                    let lyricsNoHTML = lyricsArray.map(el => {
                        let result = el.replace(/<br>/g, '\n');
                        result = result.replace(/<.+?>/g, '');
                        result = he.decode(result);
                        return result;
                    });
                    lyrics = lyricsNoHTML.join('\n');
                    const dataUnitsArray = [];
                    $("[class*='SongInfo__Credit']").each(function(i) {
                        dataUnitsArray[i] = $(this).text();
                    });
                    const dataUnits = dataUnitsArray.join(' ');
                if (lyrics) {
                        return this.getOutput(lyrics, dataUnits, fileName, htmlText);
                    } else {
                        fs.writeFileSync(`./errors/${fileName}.html`, htmlText);
                        console.log(`Lyrics could not be parsed because there is no lyrics class`);
                        return null;
                    }
                }
            }
        }

    async getSongsTexts(textsArtistInfo) {
        const completeSongs = [];
        if (textsArtistInfo.songs) {
            for (const song of textsArtistInfo.songs) {
                const maxTriesSongUrl = 5;
                for (let i = 0; i < maxTriesSongUrl; i++) {
                    const response = await axios.get(song.url, {timeout: 300000}).catch(e => console.log(e));
                    if (response) {
                        if (response.data) {
                            const maxTriesParseSong = 10;
                            for (let i = 0; i < maxTriesParseSong; i++) {
                                const songInfo = this.parseSongHTML(response.data, song.title);
                                if (songInfo === 'invalid') {
                                    console.log(`The fetched lyrics for ${song.title} are invalid`);
                                } else if (songInfo) {
                                    const {artistId, artistName} = textsArtistInfo;
                                    const txtNameFull = `${song.title}`;
                                    const txtNameShort = txtNameFull.substring(0, 50);
                                    const txtNameRelease = `${txtNameShort}${songInfo.releaseDate}`;
                                    const escapedSpecialCharactersTxtName = txtNameRelease.replace(/\W+/g, '_');
                                    const newSongInfo = {
                                        ...song, ...songInfo,
                                        artistId,
                                        artistName,
                                        txtName: escapedSpecialCharactersTxtName
                                    };
                                    completeSongs.push(newSongInfo);
                                    break;
                                } else {
                                    console.log(`The lyrics content could not be parsed for ${song.title}`);
                                }
                            }
                        } else {
                            console.log(`There were no lyrics found for ${song.title}`);
                        }
                        break;
                    }
                    // else continue
                }
            }
            return completeSongs;
        }
    }

    // TODO: Create Validator class to group all the validation methods
    validateLyrics(lyrics) {
        const checkString = 'Cliquez ici pour un meilleur aperçu';
        return !lyrics.includes(checkString)
    }

    validateLanguage(lyrics) {
        const lngDetector = new LanguageDetect();
        const detectedLanguage = lngDetector.detect(lyrics, 1);
        return detectedLanguage[0][0] === 'french';
    }

    getOutput(lyrics, dataUnits, fileName, htmlText) {
        if (lyrics && this.validateLyrics(lyrics) && this.validateLanguage(lyrics)) {
            console.log('GeniusClient.getOutput: Lyrics found successfully');
            const releaseDate = dataUnits.match(/(\w+\s[0-9]+,\s[0-9]+)/g);
            return {
                lyrics,
                releaseDate: releaseDate ? releaseDate[0] : '000000000',
            }
        } else {
            console.log('GeniusClient.getOutput: Lyrics are not valid');
            fs.writeFileSync(`./errors/invalid_${fileName}.html`, htmlText);
            return 'invalid';
        }
    }
}
