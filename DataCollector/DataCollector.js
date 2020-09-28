import {WikipediaClient} from './WikipediaClient';
import {GeniusClient} from './GeniusClient';
import * as Helpers from './Helpers';
import fs from 'fs';
import ObjectsToCsv from 'objects-to-csv';

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

const geniusBaseUrl = 'https://api.genius.com';

class DataCollector {
    constructor(wikiOptions, wordsToClean) {
        this._wikiPediaClient = new WikipediaClient();
        this._geniusClient = new GeniusClient(geniusBaseUrl);
        this._wikiOptions = wikiOptions;
        this._wordsToClean = wordsToClean;
        fs.mkdir('./files', (e) => {
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
                artists.push(entry.title);
            }
        }
        const artistsTrimmed = Helpers.cleanStrings(this._wordsToClean, artists);
        return Helpers.removeDuplicates(artistsTrimmed);
    }

    async getAllArtistsIds(artists) {
        const artistsIds = [];
        for (const artist of artists) {
            const artistInfo = await this._geniusClient.getArtistId(artist);
            if (artistInfo) {
                const {artistId} = artistInfo;
                if (artistId && artistId !== '') {
                    artistsIds.push(artistInfo);
                }
            } else {
                console.log(`DataCollector: ERROR: Artist Id was not found for artist ${artist}`);
            }
        }
        return artistsIds;
    }

    async getSongsPerArtist(getSongsArtistInfo) {
        const songs = await this._geniusClient.getSongs(getSongsArtistInfo);
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
        await csv.toDisk('./songsMetadata.csv', {append: true});
    }
}

const dataCollector = new DataCollector(wikiOptions, wordsToClean);

const main = async () => {
    const artistsNames = await dataCollector.getAllArtists();
    console.log('MAIN: Artists names have been received');
    const artistsInfos = await dataCollector.getAllArtistsIds(artistsNames);
    console.log('MAIN: Artists infos have been received');
    const artistsWithSongs = [];
    for (const artistInfo of artistsInfos) {
            const artistWithSong = await dataCollector.getSongsPerArtist(artistInfo);
            artistsWithSongs.push(artistWithSong);
    }
    console.log('MAIN: Artists with songs have been retrieved' + JSON.stringify(artistsWithSongs));
    const allSongs = []
    for (const artistWithSong of artistsWithSongs) {
        const songs = await dataCollector.getSongsTexts(artistWithSong);
        songs.forEach((song) => {
            allSongs.push(song);
            dataCollector.writeToTxt(song);
        });
    }
    console.log('MAIN: All songs have been retrieved' + JSON.stringify(allSongs));
    try {
        fs.writeFileSync('./allSongs.json', JSON.stringify(allSongs));
    } catch (e) {
        console.log(e);
    }
    await dataCollector.writeToCsv(allSongs);
}

main()
    .then(() => console.log('All done, captain!'))
        .catch((e) => console.log(e));

