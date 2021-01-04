// TODO: Create domains for logging
// TODO: Unify variable names for artist name (genius id) everywhere
import {DATA_EXTRACTOR} from "./DataExtractor";
import fs from "fs";
const fileWikiArtists = fs.readFileSync('./metadata/artists.json');
export const FILE_WIKI_ARTISTS = fileWikiArtists ? JSON.parse(fileWikiArtists.toString()): undefined;
const fileGeniusIds = fs.readFileSync('./metadata/artistsIds.json')
export const FILE_GENIUS_IDS = fileGeniusIds ? JSON.parse(fileGeniusIds.toString()): undefined;
let fileArtistsAndSongs = fs.readFileSync('./metadata/artistsWithSongs.json');
export const FILE_ARTISTS_AND_SONGS = JSON.parse(fileArtistsAndSongs.toString());


const main = async () => {
   // await DATA_EXTRACTOR.exportArtists();
   // await DATA_EXTRACTOR.exportArtistsIDs();
   // await DATA_EXTRACTOR.exportArtistsWithSongs();
   await DATA_EXTRACTOR.exportAllSongs();
}

main()
    .then(() => console.log('All done, captain!'))
    .catch((e) => console.log(e));