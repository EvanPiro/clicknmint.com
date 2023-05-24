module Curation exposing (list)

import NFT exposing (NFT)



{-
   Each curated NFT should have the following structure:
   { network = ""
   , contractAddress = ""
   , tokenId = ""
   , title = ""
   , description = ""
   , image = ""
   }
   Note that the image property is a fully qualified https URL.
-}


list : List NFT
list =
    [ { network = "sepolia"
      , contractAddress = "0xDC62D45d5C96CAFB749b5D46624E30d252C3ddb5"
      , tokenId = "1"
      , title = "Cow in a Sunset"
      , description = "JS Paint 2023"
      , image = "https://cloudflare-ipfs.com/ipfs/bafkreibx7gmbids5ozyyd3vkispugfmkrcsm5kb7lpg3ovsko6fg6y6pfa"
      , price = Nothing
      , owner = "0x1A22f8e327adD0320d7ea341dFE892e43bC60322"
      }
    , { image = "https://cloudflare-ipfs.com/ipfs/bafkreigk6qqdlmbovkatj2smw5dkx7glq4ic5w56ydg32wqazwmf66u56i"
      , tokenId = "2"
      , title = "Laughter"
      , network = "sepolia"
      , description = "MS Paint 2023"
      , price = Nothing
      , owner = "0x5c57Afeb070B0F089E4DeDE58deF524143D1b54d"
      , contractAddress = "0xDC62D45d5C96CAFB749b5D46624E30d252C3ddb5"
      }
    , { image = "https://cloudflare-ipfs.com/ipfs/bafkreiajbtv5l477zvdqy4ye5u5glh7sgf4ij35uzolkyaotjk76mtacum"
      , tokenId = "3"
      , title = "Candor"
      , network = "sepolia"
      , description = "MS Paint 2023"
      , price = Nothing
      , owner = "0x5c57Afeb070B0F089E4DeDE58deF524143D1b54d"
      , contractAddress = "0xDC62D45d5C96CAFB749b5D46624E30d252C3ddb5"
      }
    , { image = "https://cloudflare-ipfs.com/ipfs/bafkreigupts7gjtvnimkpv4vqskmgypennzqgiwuaqgyisgcsmeaxy6niy"
      , tokenId = "4"
      , title = "Spar"
      , network = "sepolia"
      , description = "MS Paint 2023"
      , price = Nothing
      , owner = "0x5c57Afeb070B0F089E4DeDE58deF524143D1b54d"
      , contractAddress = "0xDC62D45d5C96CAFB749b5D46624E30d252C3ddb5"
      }
    , { image = "https://cloudflare-ipfs.com/ipfs/bafkreid4novsnog4puxw5yhtanm33kfkszocfic3xqum3mmdglvawo6z54"
      , tokenId = "5"
      , title = "Working Man"
      , network = "sepolia"
      , description = "MS Paint 2023"
      , price = Nothing
      , owner = "0x5c57Afeb070B0F089E4DeDE58deF524143D1b54d"
      , contractAddress = "0xDC62D45d5C96CAFB749b5D46624E30d252C3ddb5"
      }
    , { image = "https://cloudflare-ipfs.com/ipfs/bafkreieob5vjosghtgtqmcfjosw7mgi3n2rcwkz23xchfwttmuxo6yj2k4"
      , tokenId = "6"
      , title = "Eucharists"
      , network = "sepolia"
      , description = "MS Paint 2023"
      , price = Nothing
      , owner = "0x5c57Afeb070B0F089E4DeDE58deF524143D1b54d"
      , contractAddress = "0xDC62D45d5C96CAFB749b5D46624E30d252C3ddb5"
      }
    , { image = "https://cloudflare-ipfs.com/ipfs/bafkreifmiiuorrq3rctrkvsx4hhvk3lcztgca6654n4ukhpt4dndfgg3na"
      , tokenId = "7"
      , title = "The Vessel"
      , network = "sepolia"
      , description = "MS Paint 2023"
      , price = Nothing
      , owner = "0x5c57Afeb070B0F089E4DeDE58deF524143D1b54d"
      , contractAddress = "0xDC62D45d5C96CAFB749b5D46624E30d252C3ddb5"
      }
    , { image = "https://cloudflare-ipfs.com/ipfs/bafkreigqhwytpndh5rttb4eyio6axsjiuuyz5tqp354dielzvg6223tpyi"
      , tokenId = "8"
      , title = "Tequila Sunrise"
      , network = "sepolia"
      , description = "MS Paint 2023"
      , price = Nothing
      , owner = "0x5c57Afeb070B0F089E4DeDE58deF524143D1b54d"
      , contractAddress = "0xDC62D45d5C96CAFB749b5D46624E30d252C3ddb5"
      }
    , { image = "https://cloudflare-ipfs.com/ipfs/bafkreif2kcnlsa74d4us33wngjnmm6ae6cc52sqa4l4zpoxrzaj7uqj4n4"
      , tokenId = "9"
      , title = "Cadence"
      , network = "sepolia"
      , description = "MS Paint 2023"
      , price = Nothing
      , owner = "0x5c57Afeb070B0F089E4DeDE58deF524143D1b54d"
      , contractAddress = "0xDC62D45d5C96CAFB749b5D46624E30d252C3ddb5"
      }
    , { image = "https://cloudflare-ipfs.com/ipfs/bafkreiau7qvi4zkai54e4kpahbkwcdm46bzrppiz6yqqex3aqla4olzbzm"
      , tokenId = "10"
      , title = "Pianoman"
      , network = "sepolia"
      , description = "MS Paint 2023"
      , price = Nothing
      , owner = "0x5c57Afeb070B0F089E4DeDE58deF524143D1b54d"
      , contractAddress = "0xDC62D45d5C96CAFB749b5D46624E30d252C3ddb5"
      }
    , { image = "https://cloudflare-ipfs.com/ipfs/bafkreiezuxtmxlqs4mdclcgm2tezpfsf73z7yavh2abyqmdyt7ekhgakiu"
      , tokenId = "11"
      , title = "Angela"
      , network = "sepolia"
      , description = "MS Paint 2023"
      , price = Nothing
      , owner = "0x5c57Afeb070B0F089E4DeDE58deF524143D1b54d"
      , contractAddress = "0xDC62D45d5C96CAFB749b5D46624E30d252C3ddb5"
      }
    ]
