import {WikipediaClient} from './WikipediaClient';
import * as Helpers from './Helpers';

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
    '(musicien)',
    '(rap)',
    '(chanteuse)',
    '(chanteur)',
    '(groupe)',
    '(collectif)',
    '(groupe de rap)',
    '(artiste)',
    '(rappeur français)'
];

class DataCollector {
    _wikiPediaClient;
    constructor(wikiOptions, wordsToClean) {
        this._wikiPediaClient = new WikipediaClient();
        this._wikiOptions = wikiOptions;
        this._wordsToClean = wordsToClean;
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

}

const dataCollector = new DataCollector(wikiOptions, wordsToClean);

dataCollector.getAllArtists()
    .then(results => console.log(results))
    .catch(e => console.log(e));