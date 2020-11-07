import {DATA_COLLECTOR} from './DataCollector';
export const FILE_WIKI_ARTISTS = require('./metadata/artists.json');
export const FILE_GENIUS_IDS = require('./metadata/artistsIds.json');
export const FILE_ARTISTS_AND_SONGS = require('./metadata/artistsWithSongs.json');
export const FILE_ALL_SONGS = require('./metadata/allSongs.json');
import fs from "fs";
export let WIKI_ARTISTS;
export let GENIUS_IDS;
export let ARTISTS_AND_SONGS;
export let ALL_SONGS;

class DataExtractor {
    async exportArtists() {
        const wikiArtists = await DATA_COLLECTOR.getAllArtists();
        const artistsNamesObject = JSON.stringify({artists: wikiArtists});
        try {
            fs.writeFileSync('./metadata/artists.json', artistsNamesObject);
        } catch (e) {
            console.log(e);
        }
        WIKI_ARTISTS = null;
        WIKI_ARTISTS = wikiArtists;
        console.log('DataExtractor.exportArtists: Artists names have been received');
    }
    async exportArtistsIDs() {
        const artists = FILE_WIKI_ARTISTS ? FILE_WIKI_ARTISTS.artists : WIKI_ARTISTS;
        const artistsIds  = await DATA_COLLECTOR.getAllArtistsIds(artists);
        const artistsIdsObject = JSON.stringify({artistsIds: artistsIds});
        fs.writeFileSync('./metadata/artistsIds.json', artistsIdsObject);
        GENIUS_IDS = null;
        GENIUS_IDS = artistsIds;
        console.log('DataExtractor.exportArtistsIDs: Artists IDs have been received');
    }

    async exportArtistsWithSongs() {
        const artistsIds = FILE_GENIUS_IDS ? FILE_GENIUS_IDS.artistsIds : GENIUS_IDS;
        const artistsWithSongs = [];
        for (const artistId of artistsIds) {
                const artistWithSong = await DATA_COLLECTOR.getSongsPerArtist(artistId);
                artistsWithSongs.push(artistWithSong);
        }
        const artistsWithSongsObject = JSON.stringify({artistsWithSongs: artistsWithSongs});
        fs.writeFileSync('./metadata/artistsWithSongs.json', artistsWithSongsObject);
        ARTISTS_AND_SONGS = null;
        ARTISTS_AND_SONGS = artistsWithSongs;
        console.log('DataExtractor.getArtistsWithSongs: Artists with songs have been retrieved');
    }

    async exportAllSongs() {
        const artistsWithSongs = FILE_ARTISTS_AND_SONGS ? FILE_ARTISTS_AND_SONGS : ARTISTS_AND_SONGS;
        const allSongs = [];
        for (const artistWithSong of artistsWithSongs) {
            const songs = await DATA_COLLECTOR.getSongsTexts(artistWithSong);
            songs.forEach((song) => {
                allSongs.push(song);
                DATA_COLLECTOR.writeToTxt(song);
            });
        }
        const allSongsObject = JSON.stringify({allSongs: allSongs})
        try {
            fs.writeFileSync('./metadata/allSongs.json', allSongsObject);
        } catch (e) {
            console.log(e);
        }
        ALL_SONGS = null;
        ALL_SONGS = allSongs;
        console.log('DataCollector.exportAllSongs: All songs have been retrieved');
        await DATA_COLLECTOR.writeToCsv(allSongs);
    }
}

export const DATA_EXTRACTOR = new DataExtractor();

