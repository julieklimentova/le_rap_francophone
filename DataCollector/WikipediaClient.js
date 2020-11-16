import axios from 'axios';

// TODO: Needs to be refactored - properties, etc.
// TODO: Need to parametrize / make configurable usage of altering and manually found artists

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
    {wikiName: 'Koma', alteredName: 'Koma (FRA)'},
    {wikiName: 'Casey', alteredName: 'Apprends à t’taire'},
    {wikiName: 'Vesti', alteredName: 'Tu captes'},
    {wikiName: 'Larry', alteredName: 'Enfant compliqué'},
    {wikiName: 'Hamed Daye', alteredName: 'Hamed Däye'},
    {wikiName: 'Heuss l\'Enfoiré', alteredName: 'Heuss L’enfoiré'},
    {wikiName: 'Jok\'Air', alteredName: 'Jok’Air'},
    {wikiName: 'Kalash l\'Afro', alteredName: 'Kalash l’Afro'},
    {wikiName: 'MC Jean Gab\'1', alteredName: 'MC Jean Gab’1'},
    {wikiName: 'Neg Lyrical', alteredName: 'Neg’Lyrical'},
    {wikiName: 'Rim\'K', alteredName: 'Rim’K'},
    {wikiName: 'Rockin\' Squat', alteredName: 'Rockin’ Squat'},
    {wikiName: 'Sat l\'Artificier', alteredName: 'Sat l’Artificier'},
    {wikiName: 'L\'Animalerie', alteredName: 'L’Animalerie'},
    {wikiName: 'L\'Armée des 12', alteredName: 'L’Armée des 12'},
    {wikiName: 'l\'atelier', alteredName: 'L’Atelier'},
    {wikiName: 'Djadja et Dinaz', alteredName: 'Djadja & Dinaz'},
    {wikiName: 'L\'Entourage', alteredName: 'L’Entourage'},
    {wikiName: 'Less du Neuf', alteredName: 'Less’ du Neuf'},
    {wikiName: 'diam\'s', alteredName: 'Diam’s'},
    {wikiName: '\'t Hof van Commerce', alteredName: '’T Hof Van Commerce'},
    {wikiName: 'L\'Skadrille', alteredName: 'L’Skadrille'},
    {wikiName: 'sexion d\'assaut', alteredName: 'Sexion d’Assaut'},
    {wikiName: 'Nèg\' Marrons', alteredName: 'Neg’ Marrons'},
    {wikiName: 'Mo\'vez Lang', alteredName: 'Mo’vez Lang'},
    {wikiName: 'Mafia K\'1 Fry', alteredName: 'Mafia K’1 Fry'},
    {wikiName: 'L\'Algérino', alteredName: 'L’Algérino'},
    {wikiName: 'D\' de Kabal', alteredName: 'D’ de Kabal'},
    {wikiName: 'Bassem Braïki', alteredName: 'Bassem Braiki'},
    {wikiName: 'Big Red', alteredName: 'Deenastyle'},
    {wikiName: 'Black M', alteredName: 'Black Mesrimes'},
    {wikiName: 'Infinit’', alteredName: 'Cigarette 2 Haine'}
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
    'Taïpan',
    'Taïro',
    'Spider ZED',
    'Framal',
    'Ladea',
    'B-lel',
    'Fayçal',
    'Primero',
    'Gracy Hopkins',
    'Musical Homicide',
    'Davodka',
    'Ynnek',
    'TiTo Prince',
    'Esso Luxueux',
    '2-Zer',
    'Oumar',
    'Gims',
    'Barack adama',
    'Escobar Macson',
    'Casey',
    'Vesti',
    'Eli MC',
    'Tonio MC',
    'Kobo',
    'Lesram',
    'Makala',
    'Tengo John',
    'Di-Meh',
    'Slimka',
    'Zoonard',
    'Infinit’'
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
