import {DataCollector} from './DataCollector';
import {FILE_WIKI_ARTISTS} from "./main";
import {FILE_GENIUS_IDS} from "./main";
import {FILE_ARTISTS_AND_SONGS} from "./main";

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
        WIKI_ARTISTS = undefined;
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
        GENIUS_IDS = artistsIds;
        await DATA_COLLECTOR.writeToCsv(artistsIds, 'artistsIds');
        console.log('DataExtractor.exportArtistsIDs: Artists IDs have been received');
    }

    async exportArtistsWithSongs() {
        const artistsIds = FILE_GENIUS_IDS ? FILE_GENIUS_IDS.artistsIds : GENIUS_IDS;
        const artistsWithSongs = [];
        const notFoundSongs = [];
        for (const artistId of artistsIds) {
                const artistWithSong = await DATA_COLLECTOR.getSongsPerArtist(artistId);
                if (artistWithSong.songs.length === 0) {
                    notFoundSongs.push(artistWithSong);
                } else {
                    artistsWithSongs.push(artistWithSong);
                }
        }
        try {
            fs.writeFileSync('./errors/notFoundSongs.json', JSON.stringify({notFoundSongs}));
        } catch(e) {
            console.log(e);
        }
        const artistsWithSongsObject = JSON.stringify({artistsWithSongs: artistsWithSongs});
        try {
            fs.writeFileSync('./metadata/artistsWithSongs.json', artistsWithSongsObject);
        } catch(e) {
            console.log(e);
        }
        ARTISTS_AND_SONGS = artistsWithSongs;
        await DATA_COLLECTOR.writeToCsv(artistsWithSongs, 'artistsWithSongs');
        console.log('DataExtractor.getArtistsWithSongs: Artists with songs have been retrieved');
    }

    async exportAllSongs() {
        const artistsWithSongs = FILE_ARTISTS_AND_SONGS ? FILE_ARTISTS_AND_SONGS.artistsWithSongs : ARTISTS_AND_SONGS;
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
        ALL_SONGS = allSongs;
        console.log('DataExtractor.exportAllSongs: All songs have been retrieved');
        await DATA_COLLECTOR.writeToCsv(allSongs, 'songsMetadata');
    }
}

export const DATA_EXTRACTOR = new DataExtractor();

