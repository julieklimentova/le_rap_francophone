import axios from 'axios';
import cheerio from 'cheerio';
import fs from 'fs';
import util from 'util';

const accessToken = '';
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
    return axios.get(`${this._baseUrl}${searchQuery}`,{headers})
        .then(response => {
            const hits = response.data.response.hits;
            // TODO: Possibly come up with a better filtering strategy and put into helpers/ as a method
            const artistsSongs = hits.filter(song => {
                const geniusName = song.result.primary_artist.name.toLowerCase().trim();
                const wikiName = artist.toLowerCase();
                let isArtist = false;
                isArtist = geniusName.includes(wikiName) ? true : false;
                if (!isArtist) {
                isArtist = wikiName.includes(geniusName) ? true : false;
                }
                const false_exceptions = ['luni', 'nubi', 'gambi', 'koma', 'sheek'];
                const true_exceptions = [
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
                if(false_exceptions.includes(wikiName)) {
                    isArtist = false;
                }
                if(true_exceptions.includes(wikiName)) {
                    isArtist = true;
                }
                return isArtist;
            });
            let artistId = '';
            let artistName = '';
            if (artistsSongs.length > 0) {
              artistId = artistsSongs[0].result.primary_artist.id ? artistsSongs[0].result.primary_artist.id : '';
              artistName = artistsSongs[0].result.primary_artist.name ? artistsSongs[0].result.primary_artist.name : '';
            } else {
                console.log(`GeniusClient: ERROR: Cannot find artist id for ${artist}`);
            }
            return {artistId, artistName};
        })
        .catch(e => console.log(e));
        }
        getSongs(getSongsArtistInfo) {
                const query = `/artists/${getSongsArtistInfo.artistId}/songs?access_token=${accessToken}`;
                return axios.get(`${this._baseUrl}${query}`, {timeout: 100000})
                .then(response => {
                const songs = [];
                for (const song of response.data.response.songs) {
                    const songObject = {
                        title: song.full_title,
                        songId: song.id,
                        url: song.url
                    };
                    songs.push(songObject);
                }
                return songs;
                })
        }

        async getSongsTexts(textsArtistInfo) {
        const parseSongHTML = (htmlText) => {
              let lyrics = '';
              let releaseDate = '';
              let $ = cheerio.load(htmlText);
              lyrics = $('.lyrics').text();
              const dataUnits = $('.metadata_unit--table_row').text();
              releaseDate = dataUnits.match(/(\w+\s[0-9]+,\s[0-9]+)/g);
              if (lyrics) {
                   console.log('GeniusClient: GetSongsTexts: Lyrics found successfully');
                   return {
                        lyrics,
                        releaseDate: releaseDate ? releaseDate[0] : 'releaseDate not found',
              }
              } else {
                    lyrics = $('div[initial-content-for=lyrics]').text();
                    if (lyrics) {
                        console.log('GeniusClient: GetSongsTexts: Lyrics found successfully');
                        const dataUnits = $('.metadata_unit--table_row').text();
                        releaseDate = dataUnits.match(/(\w+\s[0-9]+,\s[0-9]+)/g);
                        return {
                        lyrics,
                        releaseDate: releaseDate ? releaseDate[0] : 'no release date found'
                        }
                    } else {
                    console.log(`Lyrics could not be parsed because there is no lyrics class`);
                    return {
                    lyrics: 'no lyrics found',
                    releaseDate: 'no release date found',
                    }
                  }
              }
            }
        const completeSongs = [];
        if (textsArtistInfo.songs) {
            for (const song of textsArtistInfo.songs) {
                const response = await axios.get(song.url, {timeout: 100000}).catch(e => console.log(e));
                if (response.data) {
                const songInfo = parseSongHTML(response.data);
                if (songInfo) {
                const {artistId, artistName} = textsArtistInfo;
                const txtNameFull = `${song.title}`;
                const txtNameShort = txtNameFull.substring(0, 50);
                const txtNameRelease = `${txtNameShort}${songInfo.releaseDate}`;
                const escapedSpecialCharactersTxtName = txtNameRelease.replace(/\W+/g, '_');
                const newSongInfo = {...song, ...songInfo, artistId, artistName, txtName: escapedSpecialCharactersTxtName};
                completeSongs.push(newSongInfo);
                } else {
                    console.log(`The lyrics content could not be parse for ${song.title}`);
                }
                } else {
                console.log(`There were no lyrics found for ${song.title}`);
                }
            }
        }
        return completeSongs;
        }
}