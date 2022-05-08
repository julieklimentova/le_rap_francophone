export const cleanStrings = (words, artist) => {
    const wordToClean = words.filter(word => {
        return artist.includes(`${word}`);
    });
    return artist.replace(`${wordToClean}`, '').trim();
}

export const removeDuplicates = (artists) => {
    return artists.filter((item, index) => artists.indexOf(item) === index)
}
export const isDuplicated = (artistId, arrayOfIds) => {
    return arrayOfIds.filter(el => el.artistId === artistId);
};
