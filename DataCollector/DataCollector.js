import {WikipediaClient} from './WikipediaClient';



class DataCollector {
    _wikiPediaClient;
    constructor() {
        this._wikiPediaClient = new WikipediaClient();
    }

    async getAllCategories() {
        const categoriesRappers = await this._wikiPediaClient.getCategories('https://fr.wikipedia.org/w/api.php?action=query&list=categorymembers&cmtitle=', 'Cat%C3%A9gorie:Rappeur_fran%C3%A7ais');
        console.log(JSON.stringify(categories));
        const categoriesGroups = await this._wikiPediaClient.getCategories('https://fr.wikipedia.org/w/api.php?action=query&list=categorymembers&cmtitle=', 'Cat%C3%A9gorie%3AGroupe_de_hip-hop_fran%C3%A7ais');
        console.log(JSON.stringify(categoriesGroups));
    }
}

const dataCollector = new DataCollector();

dataCollector.getAllCategories();