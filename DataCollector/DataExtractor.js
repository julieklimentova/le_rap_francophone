import {DATA_COLLECTOR} from "./DataCollector";
const FILE_WIKI_ARTISTS = require('./metadata/artists.json');
const FILE_ARTISTS_IDS = require('./metadata/artistsIds.json');
import fs from "fs";
export let WIKI_ARTISTS;
export let GENIUS_IDS;
export let ARTISTS_AND_SONGS;

class DataExtractor {
    async exportArtists() {
        const wikiArtists = await DATA_COLLECTOR.getAllArtists();
        const artistsNamesObject = JSON.stringify({artists: wikiArtists});
        fs.writeFileSync('./metadata/artists.json', artistsNamesObject);
        WIKI_ARTISTS = wikiArtists;
        console.log('DataExtractor.exportArtists: Artists names have been received');
    }
    async exportArtistsIDs() {
        const artists = FILE_WIKI_ARTISTS ? FILE_WIKI_ARTISTS.artists : WIKI_ARTISTS;
        const artistsIds  = await DATA_COLLECTOR.getAllArtistsIds(artists);
        const artistsIdsObject = JSON.stringify({artistsIds: artistsIds});
        fs.writeFileSync('./metadata/artistsIds.json', artistsIdsObject);
        GENIUS_IDS = artistsIds;
        console.log('DataExtractor.exportArtistsIDs: Artists IDs have been received');
    }
    async getArtistsWithSongs() {
        const artistsIds = FILE_ARTISTS_IDS ? FILE_ARTISTS_IDS.artistsIds : GENIUS_IDS;
        const artistsWithSongs = [];
        // for (const artistInfo of artistsInfos) {
        //         const artistWithSong = await dataCollector.getSongsPerArtist(artistInfo);
        //         artistsWithSongs.push(artistWithSong);
        // }
    }
}

