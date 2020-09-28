 export const cleanStrings = (words, artists) => {
            return artists.map(artist => {
                const wordToClean = words.filter(word => {
                   return artist.includes(`${word}`);
                });
                return artist.replace(`${wordToClean}`, '').trim();
            });
    }

export const removeDuplicates = (artists) => {
    return artists.filter((item, index) => artists.indexOf(item) === index)
}