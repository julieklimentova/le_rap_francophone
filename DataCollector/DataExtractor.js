import {DataCollector} from './DataCollector';
export let FILE_WIKI_ARTISTS;
export let FILE_GENIUS_IDS;
export let FILE_ARTISTS_AND_SONGS;
export let FILE_ALL_SONGS;
import fs from "fs";
export let WIKI_ARTISTS;
export let GENIUS_IDS;
export let ARTISTS_AND_SONGS;
export let ALL_SONGS;

const wikiOptions = {
    apiUrl: 'https://fr.wikipedia.org/w/api.php?action=query&list=categorymembers&cmtitle=',
    categories: [
        'Cat%C3%A9gorie:Rappeur_fran%C3%A7ais',
        'Cat%C3%A9gorie%3ARappeur_belge',
        'Cat%C3%A9gorie%3AGroupe_de_hip-hop_fran%C3%A7ais',
        'Cat%C3%A9gorie%3AGroupe_de_hip-hop_belge',
        'Cat%C3%A9gorie%3ARappeuse_belge',
        'Cat%C3%A9gorie%3ARappeuse_fran%C3%A7aise'
    ],
}

const wordsToClean = [
    '(rappeur)',
    '(rappeuse)',
    '(musicien)',
    '(rap)',
    '(chanteuse)',
    '(chanteur)',
    '(groupe)',
    '(collectif)',
    '(groupe de rap)',
    '(artiste)',
    '(rappeur français)',
    '(groupe belge)'
];

const DATA_COLLECTOR = new DataCollector(wikiOptions, wordsToClean);

class DataExtractor {
    async exportArtists() {
        const wikiArtists = await DATA_COLLECTOR.getAllArtists();
        const artistsNamesObject = JSON.stringify({artists: wikiArtists});
        try {
            fs.writeFileSync('./metadata/artists.json', artistsNamesObject);
        } catch (e) {
            console.log(e);
        }
        FILE_WIKI_ARTISTS = null;
        fs.readFile('./metadata/artists.json', (err, data) => {
            if (err)  console.log(err);
            FILE_WIKI_ARTISTS = JSON.parse(data);
        });
        WIKI_ARTISTS = wikiArtists;
        console.log('DataExtractor.exportArtists: Artists names have been received');
    }
    async exportArtistsIDs() {
        const artists = FILE_WIKI_ARTISTS ? FILE_WIKI_ARTISTS.artists : WIKI_ARTISTS;
        const artistsIds  = await DATA_COLLECTOR.getAllArtistsIds(artists);
        const artistsIdsObject = JSON.stringify({artistsIds: artistsIds});
        try {
            fs.writeFileSync('./metadata/artistsIds.json', artistsIdsObject);
        } catch (e) {
                console.log(e);
        }
        FILE_GENIUS_IDS = null;
        fs.readFile('./metadata/artistsIds.json', (err, data) => {
            if (err)  console.log(err);
            FILE_GENIUS_IDS = JSON.parse(data);
        });
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
        try {
            fs.writeFileSync('./metadata/artistsWithSongs.json', artistsWithSongsObject);
        } catch(e) {
            console.log(e);
        }
        FILE_ARTISTS_AND_SONGS = null;
        fs.readFile('./metadata/artistsWithSongs.json', (err, data) => {
            if (err)  console.log(err);
            FILE_ARTISTS_AND_SONGS = JSON.parse(data);
        });
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
        FILE_ALL_SONGS = null;
        fs.readFile('./metadata/allSongs.json', (err, data) => {
            if (err)  console.log(err);
            FILE_ALL_SONGS = JSON.parse(data);
        });
        ALL_SONGS = null;
        ALL_SONGS = allSongs;
        console.log('DataExtractor.exportAllSongs: All songs have been retrieved');
        await DATA_COLLECTOR.writeToCsv(allSongs);
    }
}

export const DATA_EXTRACTOR = new DataExtractor();

