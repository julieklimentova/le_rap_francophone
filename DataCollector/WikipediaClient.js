import axios from 'axios';


export class WikipediaClient {
    getCategories(url, category) {
        return axios.get(`${url}${category}&format=json&cmlimit=500`)
            .then(categories => categories.data)
            .catch(e => console.log(e));
    }
}
