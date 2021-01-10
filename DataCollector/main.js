// TODO: Create domains for logging
// TODO: Unify variable names for artist name (genius id) everywhere
import {DATA_EXTRACTOR} from "./DataExtractor";
import fs from "fs";
let fileWikiArtists;
    try {
       fileWikiArtists = fs.readFileSync('./metadata/artists.json');
    } catch (e) {
      console.log(e);
    }
export const FILE_WIKI_ARTISTS = fileWikiArtists ? JSON.parse(fileWikiArtists.toString()): undefined;
let fileGeniusIds;
try {
   fileGeniusIds = fs.readFileSync('./metadata/artistsIds.json')
} catch (e) {
   console.log(e);
}
export const FILE_GENIUS_IDS = fileGeniusIds ? JSON.parse(fileGeniusIds.toString()): undefined;

let fileArtistsAndSongs;
try {
   fileArtistsAndSongs = fs.readFileSync('./metadata/artistsWithSongs.json');
} catch (e) {
   console.log(e);
}
export const FILE_ARTISTS_AND_SONGS = fileArtistsAndSongs ? JSON.parse(fileArtistsAndSongs.toString()): undefined;


const main = async () => {
   // await DATA_EXTRACTOR.exportArtists();
   // await DATA_EXTRACTOR.exportArtistsIDs();
   await DATA_EXTRACTOR.exportArtistsWithSongs();
   await DATA_EXTRACTOR.exportAllSongs();
}

main()
    .then(() => console.log('All done, captain!'))
    .catch((e) => console.log(e));