import axios from 'axios';

// TODO: Needs to be refactored - properties, etc.
// TODO: Need to parametrize / make configurable usage of altering and manually found artists

const artistsToAlter = [
    {wikiName: 'Nakk', geniusSearchName: 'Nakk Mendosa'},
    {wikiName: 'Catégorie:Damso', geniusSearchName: 'Damso'},
    {wikiName: 'Ali', geniusSearchName: 'Ali (FRA)'},
    {wikiName: 'Loud', geniusSearchName: 'Simone Cliche Trudeau'},
    {wikiName: 'Akhenaton', geniusSearchName: 'Sentenza'},
    {wikiName: 'IAM', geniusSearchName: 'Akhenaton – Shurik\'n'},
    {wikiName: 'Shurik\'n', geniusSearchName: 'Shurik\'N Chang-Ti'},
    {wikiName: 'Disiz', geniusSearchName: 'Disiz La Peste'},
    {wikiName: 'Sofiane Zermani', geniusSearchName: 'Fiansoman'},
    {wikiName: 'Passi', geniusSearchName: 'Les flammes du mal'},
    {wikiName: 'Brav', geniusSearchName: 'Prolétariat'},
    {wikiName: 'Calbo', geniusSearchName: 'Le métier rentre'},
    {wikiName: 'Blacko', geniusSearchName: 'Blacko (FRA)'},
    {wikiName: 'Koma', geniusSearchName: 'Koma (FRA)'},
    {wikiName: 'Casey', geniusSearchName: 'Apprends à t’taire'},
    {wikiName: 'Vesti', geniusSearchName: 'Tu captes'},
    {wikiName: 'Larry', geniusSearchName: 'Enfant compliqué'},
    {wikiName: 'Hamed Daye', geniusSearchName: 'Hamed Däye'},
    {wikiName: 'Heuss l\'Enfoiré', geniusSearchName: 'Heuss L’enfoiré'},
    {wikiName: 'Jok\'Air', geniusSearchName: 'Jok’Air'},
    {wikiName: 'Kalash l\'Afro', geniusSearchName: 'Kalash l’Afro'},
    {wikiName: 'MC Jean Gab\'1', geniusSearchName: 'MC Jean Gab’1'},
    {wikiName: 'Neg Lyrical', geniusSearchName: 'Neg’Lyrical'},
    {wikiName: 'Rim\'K', geniusSearchName: 'Rim’K'},
    {wikiName: 'Rockin\' Squat', geniusSearchName: 'Rockin’ Squat'},
    {wikiName: 'Sat l\'Artificier', geniusSearchName: 'Sat l’Artificier'},
    {wikiName: 'L\'Animalerie', geniusSearchName: 'L’Animalerie'},
    {wikiName: 'L\'Armée des 12', geniusSearchName: 'L’Armée des 12'},
    {wikiName: 'l\'atelier', geniusSearchName: 'L’Atelier'},
    {wikiName: 'Djadja et Dinaz', geniusSearchName: 'Djadja & Dinaz'},
    {wikiName: 'L\'Entourage', geniusSearchName: 'L’Entourage'},
    {wikiName: 'Less du Neuf', geniusSearchName: 'Less’ du Neuf'},
    {wikiName: 'Diam\'s', geniusSearchName: 'Diam’s'},
    {wikiName: '\'t Hof van Commerce', geniusSearchName: '’T Hof Van Commerce'},
    {wikiName: 'L\'Skadrille', geniusSearchName: 'L’Skadrille'},
    {wikiName: 'sexion d\'assaut', geniusSearchName: 'Sexion d’Assaut'},
    {wikiName: 'Nèg\' Marrons', geniusSearchName: 'Neg’ Marrons'},
    {wikiName: 'Mo\'vez Lang', geniusSearchName: 'Mo’vez Lang'},
    {wikiName: 'Mafia K\'1 Fry', geniusSearchName: 'Mafia K’1 Fry'},
    {wikiName: 'L\'Algérino', geniusSearchName: 'L’Algérino'},
    {wikiName: 'D\' de Kabal', geniusSearchName: 'D’ de Kabal'},
    {wikiName: 'Bassem Braïki', geniusSearchName: 'Bassem Braiki'},
    {wikiName: 'Big Red', geniusSearchName: 'Deenastyle'},
    {wikiName: 'Black M', geniusSearchName: 'Black Mesrimes'},
    {wikiName: 'Infinit’', geniusSearchName: 'Cigarette 2 Haine'},
    {wikiName: 'Ben-J', geniusSearchName: 'Ben-J (FRA)'},
    {wikiName: 'Utilisateur:RapFrFAN/Dakeez', geniusSearchName: 'Dakeez'},
    {wikiName: 'Féfé', geniusSearchName: 'Soldat fou'},
    {wikiName: 'Gambi', geniusSearchName: 'Gambino Jetski'},
    {wikiName: 'Luni', geniusSearchName: 'Lunikar'},
    {wikiName: 'Nubi', geniusSearchName: 'Engrenage'},
    {wikiName: 'Ol Kainry', geniusSearchName: 'Ol’ Kainry'},
    {wikiName: 'Pih Poh', geniusSearchName: 'Pihpoh'},
    {wikiName: 'Virus', geniusSearchName: 'Cafarnaüm'},
    {wikiName: 'Assassin', geniusSearchName: 'Assassin (FRA)'},
    {wikiName: 'L\'Atelier', geniusSearchName: 'L’Atelier'},
    {wikiName: 'ATK', geniusSearchName: '7ème sens'},
    {wikiName: 'Ministère des affaires populaires', geniusSearchName: 'Manich Mena'},
    {wikiName: 'One Shot', geniusSearchName: 'One Shot (Rapper)'},
    {wikiName: 'Sexion d\'assaut', geniusSearchName: 'Avant qu\'elle parte'},
    {wikiName: 'Ness & Cité', geniusSearchName: 'Rîmes et bâtiments'}
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
    // TODO: assign in constructor, ideally make it an argument
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
            geniusArtist = isToAlter[0].geniusSearchName;
        }
        return geniusArtist;
    }
}
