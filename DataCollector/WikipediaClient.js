import axios from 'axios';


const artistsToAlter = [
    {wikiName: 'Nakk', alteredName: 'Nakk Mendosa'}
];
export class WikipediaClient {
    getArtists(url, category) {
        return axios.get(`${url}${category}&format=json&cmlimit=500`)
            .then(categories => categories.data)
            .catch(e => console.log(e));
    }
    alterArtist(artist) {
        let geniusArtist = artist;
        const isToAlter = artistsToAlter.filter(el => {
            return el.wikiName === artist;
        });
        if (isToAlter.length > 0) {
            geniusArtist = isToAlter[0].alteredName;
        }
        return geniusArtist;
    }
}
