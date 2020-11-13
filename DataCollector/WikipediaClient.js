import axios from 'axios';

// TODO: Needs to be refactored - properties, etc.


const artistsToAlter = [
    {wikiName: 'Nakk', alteredName: 'Nakk Mendosa'},
    {wikiName: 'Catégorie:Damso', alteredName: 'Damso'},
    {wikiName: 'Ali', alteredName: 'Ali (FRA)'},
    {wikiName: 'Loud', alteredName: 'Simone Cliche Trudeau'},
    {wikiName: 'Akhenaton', alteredName: 'Sentenza'},
    {wikiName: 'Akhenaton – Shurik\'n', alteredName: 'IAM'},
    {wikiName: 'Shurik\'n', alteredName: 'Shurik\'N Chang-Ti'},
    {wikiName: 'Disiz', alteredName: 'Disiz La Peste'},
    {wikiName: 'Sofiane Zermani', alteredName: 'Fiansoman'},
    {wikiName: 'Passi', alteredName: 'Les flammes du mal'},
    {wikiName: 'Brav', alteredName: 'Prolétariat'},
    {wikiName: 'Calbo', alteredName: 'Le métier rentre'},
    {wikiName: 'Blacko', alteredName: 'Blacko (FRA)'},
];

const moreArtists = [
    'Népal',
    'A2H',
    'Malekal Morte',
    'Keroué',
    'Vidji',
    'Espiiem',
    'Sopico',
    'Veerus',
    'Psmaker',
    'Carpe Diem',
    'Veust',
    'Krisy',
    'Heskis',
    'Jarod',
    'Tiers',
    'Swift Guad',
    'Lacraps',
    'Darryl Zeuja',
    'Mokless',
    'Koriass',
    'Prince Wally',
    'Gros Mo',
    'Swing Siméon',
    'Despo Rutti',
    'Waltmann',
    'Doums',
    'Lalcko',
    'L\'Indis',
    'Senamo',
    'So Clock',
    'Fonky Flav',
    'Seyté',
    'Taïpan'
];

export class WikipediaClient {
    artistsToAlter = artistsToAlter;
    artistsToAdd = moreArtists;
    getArtists(url, category) {
        return axios.get(`${url}${category}&format=json&cmlimit=500`)
            .then(categories => categories.data)
            .catch(e => console.log(e));
    }
    alterArtist(artist) {
        let geniusArtist = artist;
        const isToAlter = this.artistsToAlter.filter(el => {
            return el.wikiName === artist;
        });
        if (isToAlter.length > 0) {
            geniusArtist = isToAlter[0].alteredName;
        }
        return geniusArtist;
    }
}
