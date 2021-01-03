// TODO: Create domains for logging
// TODO: Unify variable names for artist name (genius id) everywhere
import {DATA_EXTRACTOR} from "./DataExtractor";
import fs from "fs";
const fileWikiArtists = fs.readFileSync('./metadata/artists.json');
export const FILE_WIKI_ARTISTS = JSON.parse(fileWikiArtists.toString());
const fileGeniusIds = fs.readFileSync('./metadata/artistsIds.json')
export const FILE_GENIUS_IDS = JSON.parse(fileGeniusIds.toString());


export let FILE_ARTISTS_AND_SONGS;
let fileArtistsAndSongs;
// try {
//    fileArtistsAndSongs = fs.readFileSync('./metadata/artistsWithSongs.json')
//    FILE_ARTISTS_AND_SONGS = JSON.parse(fileArtistsAndSongs);
// } catch (e) {
//    console.log(e);
// }

const main = async () => {
   // await DATA_EXTRACTOR.exportArtists();
   // await DATA_EXTRACTOR.exportArtistsIDs();
   await DATA_EXTRACTOR.exportArtistsWithSongs();
   // await DATA_EXTRACTOR.exportAllSongs();
}

main()
    .then(() => console.log('All done, captain!'))
    .catch((e) => console.log(e));