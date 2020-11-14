import {WikipediaClient} from './WikipediaClient';
import {GeniusClient} from './GeniusClient';
import * as Helpers from './Helpers';
import fs from 'fs';
import ObjectsToCsv from 'objects-to-csv';
const geniusBaseUrl = 'https://api.genius.com';

export class DataCollector {
    constructor(wikiOptions, wordsToClean) {
        this._wikiPediaClient = new WikipediaClient();
        this._geniusClient = new GeniusClient(geniusBaseUrl);
        this._wikiOptions = wikiOptions;
        this._wordsToClean = wordsToClean;
        fs.mkdir('./files', (e) => {
            console.log(e);
        })
        fs.mkdir('./errors', (e) => {
            console.log(e);
        })
        fs.mkdir('./metadata', (e) => {
            console.log(e);
        })
    }

    async getAllArtists() {
        const artists = [];
        const {apiUrl, categories} = this._wikiOptions;
        for (const category of categories) {
            const result = await this._wikiPediaClient.getArtists(apiUrl, category);
            const categoryMembers = result.query.categorymembers;
            for (const entry of categoryMembers) {
                const artist = this._wikiPediaClient.alterArtist(entry.title);
                artists.push(artist);
            }
            for (const entry of this._wikiPediaClient.artistsToAdd) {
                const artist = this._wikiPediaClient.alterArtist(entry);
                artists.push(artist);
            }
        }
        const artistsTrimmed = Helpers.cleanStrings(this._wordsToClean, artists);
        return Helpers.removeDuplicates(artistsTrimmed);
    }

    async getAllArtistsIds(artists) {
        const artistsIds = [];
        for (const artist of artists) {
            const maxTries = 3;
            for (let i = 0; i < maxTries; i++) {
                const artistInfos = await this._geniusClient.getArtistId(artist);
                if (artistInfos.length > 0) {
                    for (const artistInfo of artistInfos) {
                        const {artistId} = artistInfo;
                        if (artistId && artistId !== '') {
                            const isDuplicated = Helpers.isDuplicated(artistId, artistsIds);
                            if (isDuplicated.length === 0) {
                                artistsIds.push(artistInfo);
                            } // else continue
                        }
                    }
                } else {
                    console.log(`DataCollector.getAllArtistsIds: ERROR: Artist Id was not found for artist ${artist}`);
                }
            }
        }
        return artistsIds;
    }

    async getSongsPerArtist(getSongsArtistInfo) {
        let songs = [];
        const maxTries = 5;
        for (let i = 0; i < maxTries; i++) {
            songs = await this._geniusClient.getSongs(getSongsArtistInfo);
            if (songs.length > 0) {
                break;
            } // else continue
        }
        return {...getSongsArtistInfo, songs};
    }

    async getSongsTexts(textArtistInfo) {
        return this._geniusClient.getSongsTexts(textArtistInfo);
    }
    writeToTxt(song) {
        if (!song.lyrics.includes('no lyrics found')) {
            try {
                fs.writeFileSync(`./files/${song.txtName}.txt`, song.lyrics);
            } catch (e) {
                console.log(e);
            }
        }
    }
    async writeToCsv(objects) {
        const csv = new ObjectsToCsv(objects);
        await csv.toDisk('./metadata/songsMetadata.csv', {append: true});
    }
}




