import axios from 'axios';
import cheerio from 'cheerio';
import LanguageDetect from 'languagedetect';
import he from 'he';
import fs from 'fs';
import {isDuplicated} from "./Helpers";
import {FILE_GENIUS_IDS} from "./DataExtractor";

// TODO: Needs to be refactored - properties, etc.
const accessToken = 'k5wFaR-smIgqySdPhlx70AaYYBAH3KspLSEWK_dsjfDCA9R8_zvrviDGWEYZiTRo';
const headers = {
    'Authorization': `Bearer ${accessToken}`
}

const exceptionIDs = [
    {geniusSearchName: 'Simone Cliche Trudeau', geniusId: 'Loud'},
    {geniusSearchName: 'Sentenza', geniusId: 'Akhenaton'},
    {geniusSearchName: 'Akhenaton – Shurik\'n', geniusId: 'IAM'},
    {geniusSearchName: 'Shurik\'N Chang-Ti', geniusId: 'Shurik’n'},
    {geniusSearchName: 'Psmaker', geniusId: 'ISHA'},
    {geniusSearchName: 'Bigflo et Oli', geniusId: 'Bigflo & Oli'},
    {geniusSearchName: 'Fiansoman', geniusId: 'Sofiane'},
    {geniusSearchName: 'Les flammes du mal', geniusId: 'Passi'},
    {geniusSearchName: 'Némir', geniusId: 'Nemir'},
    {geniusSearchName: 'Swing Siméon', geniusId: 'Swing'},
    {geniusSearchName: 'Prolétariat', geniusId: 'Brav'},
    {geniusSearchName: 'Le métier rentre', geniusId: 'Calbo'},
    {geniusSearchName: 'JoeyStarr', geniusId: 'Joey Starr'},
    {geniusSearchName: 'Musical Homicide', geniusId: 'luXe'},
    {geniusSearchName: 'Apprends à t’taire', geniusId: 'Casey'},
    {geniusSearchName: 'Enfant compliqué', geniusId: 'Larry'},
    {geniusSearchName: 'Deenastyle', geniusId: 'Big Red'},
    {geniusSearchName: 'Black Mesrimes', geniusId: 'Black M'},
    {geniusSearchName: 'Cigarette 2 Haine', geniusId: 'Infinit’'},
    {geniusSearchName: 'Soldat Fou', geniusId: 'Féfé'},
    {geniusSearchName: 'Gambino Jetski', geniusId: 'Gambi'},
    {geniusSearchName: 'Lunikar', geniusId: 'Luni'},
    {geniusSearchName: 'Moussa Mansaly', geniusId: 'Sam’s'},
    {geniusSearchName: 'Missié GG', geniusId: 'Fuckly'},
    {geniusSearchName: 'Engrenage', geniusId: 'Nubi'},
    {geniusSearchName: 'Cafarnaüm', geniusId: 'Virus'},
    {geniusSearchName: '7ème sens', geniusId: 'ATK'},
    {geniusSearchName: 'Manich Mena', geniusId: 'M.A.P'},
    {geniusSearchName: 'Avant qu\'elle parte\'', geniusId: 'Sexion d\'Assaut'},
    {geniusSearchName: 'Rîmes et bâtiments', geniusId: 'Ness & Cité'},
    {geniusSearchName: 'La Tour des Miracles', geniusId: 'Axios'},
    {geniusSearchName: 'Le Maire de la ville', geniusId: 'Driver'},
    {geniusSearchName: 'Comme un rat dans l’coin', geniusId: 'Fabe'},
    {geniusSearchName: 'Salim Lakhdari', geniusId: 'LIM'},
    {geniusSearchName: 'Dybala', geniusId: 'Maes'},
    {geniusSearchName: 'Le Vrai Michel', geniusId: 'Michel'},
    {geniusSearchName: 'Ghislain Loussingu', geniusId: 'Mystik'},
    {geniusSearchName: 'Loin de moi', geniusId: 'Naza'},
    {geniusSearchName: 'Allô Maman', geniusId: 'SCH'},
    {geniusSearchName: 'Six Coups MC', geniusId: 'Six'},
    {geniusSearchName: 'Chez Wam', geniusId: 'Sultan'},
    {geniusSearchName: 'Tanguy Destable', geniusId: 'Tepr'},
    {geniusSearchName: 'Ces soirées-là', geniusId: 'Yannick'},
    {geniusSearchName: 'Aurélien N\'Zuzi Zola', geniusId: 'Zola'},
    {geniusSearchName: 'Walygator', geniusId: 'Prince Wally'},
    {geniusSearchName: 'Mon Coca et mes nikes', geniusId: 'Akro'},
    {geniusSearchName: 'DJ d’enfer', geniusId: 'Benny B'}
];

export class GeniusClient {
    // TODO: assign in constructor, ideally make it an argument
    exceptionIDs = exceptionIDs;

    constructor(baseUrl) {
        this._baseUrl = baseUrl;
    }
    // TODO: This method together with the wiki method could be refactored and put to helpers
    alterArtist(artist) {
        let wikiName = artist;
        const isToAlter = this.exceptionIDs.filter(el => {
            return el.geniusSearchName === wikiName;
        });
        if (isToAlter.length > 0) {
            wikiName = isToAlter[0].geniusId;
        }
        return wikiName;
    }

    getArtistId(artist) {
        const encodedArtist = encodeURI(artist);
        const searchQuery = `/search?q=${encodedArtist}`;
        let notFound;
        return axios.get(`${this._baseUrl}${searchQuery}`, {timeout: 200000, headers})
            .then(response => {
                const hits = response.data.response.hits ? response.data.response.hits : [];
                // TODO: Possibly come up with a better filtering strategy and put into helpers/ as a method
                const artistsSongs = hits.filter(song => {
                    const geniusName = song.result.primary_artist.name.toLowerCase().trim();
                    let searchName = this.alterArtist(artist);
                    searchName = searchName.toLowerCase();
                    let isArtist = geniusName.includes(searchName) ? true : false;
                    if (!isArtist) {
                        isArtist = searchName.includes(geniusName) ? true : false;
                    }
                    const false_exceptions = ['sheek', 'al', 'east', 'narcisse', 'lorca'];
                    if (false_exceptions.includes(searchName)) {
                        isArtist = false;
                    }
                    return isArtist;
                });
                let geniusSearchName = artist;
                let resultingGeniusArtists = [];
                if (artistsSongs.length > 0) {
                    notFound = undefined;
                    for (const song of artistsSongs) {
                        const artistId = artistsSongs[0].result.primary_artist.id ? artistsSongs[0].result.primary_artist.id : '';
                        const geniusId = artistsSongs[0].result.primary_artist.name ? artistsSongs[0].result.primary_artist.name : '';
                        const isArtistDuplicated = isDuplicated(artistId, resultingGeniusArtists);
                        if (isArtistDuplicated.length === 0) {
                            resultingGeniusArtists.push({artistId, geniusId, geniusSearchName});
                        }
                    }
                } else {
                    console.log(`GeniusClient: ERROR: Cannot find artist id for ${artist}`);
                    notFound = artist;
                }
                return {resultingGeniusArtists: resultingGeniusArtists, notFound};
            })
            .catch(e => {
                    console.log(e)
                    return null;
                }
            );
    }

    async getSongs(getSongsArtistInfo) {
        const artistShortcut = getSongsArtistInfo.artistName.slice(0, 4).toUpperCase();
        const query = `/artists/${getSongsArtistInfo.artistId}/songs?access_token=${accessToken}`;
        const songs = [];
        await axios.get(`${this._baseUrl}${query}`, {timeout: 200000})
            .then(response => {
                if (response.data) {
                    let numberId = 1;
                    for (const song of response.data.response.songs) {
                        const songObject = {
                            songShortcut:`${artistShortcut}${numberId}`,
                            title: song.full_title,
                            songId: song.id,
                            url: song.url
                        };
                        numberId++;
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
                $("[class*='Lyrics__Container']").each(function (i) {
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
                $("[class*='SongInfo__Credit']").each(function (i) {
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
                                    const newSongInfo = {
                                        ...song, ...songInfo,
                                        artistId,
                                        artistName,
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
