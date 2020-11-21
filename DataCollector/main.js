import {DATA_EXTRACTOR} from "./DataExtractor";

const main = async () => {
   await DATA_EXTRACTOR.exportArtists();
   await DATA_EXTRACTOR.exportArtistsIDs();
   // await DATA_EXTRACTOR.exportArtistsWithSongs();
   // await DATA_EXTRACTOR.exportAllSongs();
}

main()
    .then(() => console.log('All done, captain!'))
    .catch((e) => console.log(e));