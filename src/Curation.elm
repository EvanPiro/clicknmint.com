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
      , contractAddress = "0xa47d17727fDe3826d92A77BE2f83F6fb1d7254e8"
      , tokenId = "22"
      , title = "Cow in a Sunset"
      , description = "MS Paint 2023"
      , image = "https://cloudflare-ipfs.com/ipfs/bafkreibx7gmbids5ozyyd3vkispugfmkrcsm5kb7lpg3ovsko6fg6y6pfa"
      , price = Nothing
      , owner = "0x1A22f8e327adD0320d7ea341dFE892e43bC60322"
      }
    , { network = "sepolia"
      , contractAddress = "0xa47d17727fDe3826d92A77BE2f83F6fb1d7254e8"
      , tokenId = "22"
      , title = "Lambmeter"
      , description = "MS Paint 2023"
      , image = "https://cloudflare-ipfs.com/ipfs/bafkreifrnvgqnsfpwk2luoet3i3tvb3fet7b73prnk3mnlaugysg3offle"
      , price = Nothing
      , owner = "0x1A22f8e327adD0320d7ea341dFE892e43bC60322"
      }
    , { network = "sepolia"
      , contractAddress = "0xa47d17727fDe3826d92A77BE2f83F6fb1d7254e8"
      , tokenId = "21"
      , title = "Body Quest"
      , description = "MS Paint 2023"
      , image = "https://cloudflare-ipfs.com/ipfs/bafkreier7xciixmfazagxmu7gswci6ydtcnbztxwczripvvnmhpnnmhi2a"
      , price = Nothing
      , owner = "0x1A22f8e327adD0320d7ea341dFE892e43bC60322"
      }
    , { network = "sepolia"
      , contractAddress = "0xa47d17727fDe3826d92A77BE2f83F6fb1d7254e8"
      , tokenId = "20"
      , title = "Jeans"
      , description = "MS Paint 2023"
      , image = "https://cloudflare-ipfs.com/ipfs/bafkreiezuxtmxlqs4mdclcgm2tezpfsf73z7yavh2abyqmdyt7ekhgakiu"
      , price = Nothing
      , owner = "0x1A22f8e327adD0320d7ea341dFE892e43bC60322"
      }
    , { network = "goerli"
      , contractAddress = "0x25b6364A5979e0e7C2ca3124d3b5d0A365EF1259"
      , tokenId = "0"
      , title = "Piano"
      , description = "MS Paint 2023"
      , image = "https://cloudflare-ipfs.com/ipfs/bafkreiau7qvi4zkai54e4kpahbkwcdm46bzrppiz6yqqex3aqla4olzbzm"
      , price = Nothing
      , owner = "0x1A22f8e327adD0320d7ea341dFE892e43bC60322"
      }
    , { network = "sepolia"
      , contractAddress = "0xa47d17727fDe3826d92A77BE2f83F6fb1d7254e8"
      , tokenId = "19"
      , title = "Candor"
      , description = "MS Paint 2023"
      , image = "https://cloudflare-ipfs.com/ipfs/bafkreiajbtv5l477zvdqy4ye5u5glh7sgf4ij35uzolkyaotjk76mtacum"
      , price = Nothing
      , owner = "0x1A22f8e327adD0320d7ea341dFE892e43bC60322"
      }
    , { network = "sepolia"
      , contractAddress = "0xa47d17727fDe3826d92A77BE2f83F6fb1d7254e8"
      , tokenId = "18"
      , title = "Cadence"
      , description = "MS Paint 2023"
      , image = "https://cloudflare-ipfs.com/ipfs/bafkreif2kcnlsa74d4us33wngjnmm6ae6cc52sqa4l4zpoxrzaj7uqj4n4"
      , price = Nothing
      , owner = "0x1A22f8e327adD0320d7ea341dFE892e43bC60322"
      }
    , { network = "sepolia"
      , contractAddress = "0xa47d17727fDe3826d92A77BE2f83F6fb1d7254e8"
      , tokenId = "17"
      , title = "Disambuation"
      , description = "MS Paint 2023"
      , image = "https://cloudflare-ipfs.com/ipfs/bafkreiaquiyls7oaag5hubgdjckhusry2asm5ipstepeiclpv4uftnbtca"
      , price = Nothing
      , owner = "0x1A22f8e327adD0320d7ea341dFE892e43bC60322"
      }
    , { network = "sepolia"
      , contractAddress = "0xa47d17727fDe3826d92A77BE2f83F6fb1d7254e8"
      , tokenId = "16"
      , title = "Tequila Sunrise"
      , description = "MS Paint 2023"
      , image = "https://cloudflare-ipfs.com/ipfs/bafkreigqhwytpndh5rttb4eyio6axsjiuuyz5tqp354dielzvg6223tpyi"
      , price = Nothing
      , owner = "0x1A22f8e327adD0320d7ea341dFE892e43bC60322"
      }
    , { network = "sepolia"
      , contractAddress = "0xa47d17727fDe3826d92A77BE2f83F6fb1d7254e8"
      , tokenId = "15"
      , title = "Horse Crow"
      , description = "MS Paint 2023"
      , image = "https://cloudflare-ipfs.com/ipfs/bafkreigk6qqdlmbovkatj2smw5dkx7glq4ic5w56ydg32wqazwmf66u56i"
      , price = Nothing
      , owner = "0x1A22f8e327adD0320d7ea341dFE892e43bC60322"
      }
    , { network = "sepolia"
      , contractAddress = "0xa47d17727fDe3826d92A77BE2f83F6fb1d7254e8"
      , tokenId = "11"
      , title = "Vessel"
      , description = "MS Paint 2023"
      , image = "https://cloudflare-ipfs.com/ipfs/bafkreifmiiuorrq3rctrkvsx4hhvk3lcztgca6654n4ukhpt4dndfgg3na"
      , price = Nothing
      , owner = "0x1A22f8e327adD0320d7ea341dFE892e43bC60322"
      }
    , { network = "sepolia"
      , contractAddress = "0xa47d17727fDe3826d92A77BE2f83F6fb1d7254e8"
      , tokenId = "6"
      , title = "Figures"
      , description = "MS Paint 2023"
      , image = "https://cloudflare-ipfs.com/ipfs/bafkreid4novsnog4puxw5yhtanm33kfkszocfic3xqum3mmdglvawo6z54"
      , price = Nothing
      , owner = "0x1A22f8e327adD0320d7ea341dFE892e43bC60322"
      }
    , { network = "sepolia"
      , contractAddress = "0xa47d17727fDe3826d92A77BE2f83F6fb1d7254e8"
      , tokenId = "7"
      , title = "Orbs"
      , description = "MS Paint 2023"
      , image = "https://cloudflare-ipfs.com/ipfs/bafkreieob5vjosghtgtqmcfjosw7mgi3n2rcwkz23xchfwttmuxo6yj2k4"
      , price = Nothing
      , owner = "0x1A22f8e327adD0320d7ea341dFE892e43bC60322"
      }
    , { network = "sepolia"
      , contractAddress = "0xa47d17727fDe3826d92A77BE2f83F6fb1d7254e8"
      , tokenId = "8"
      , title = "The Golden Ratio"
      , description = "MS Paint 2023"
      , image = "https://cloudflare-ipfs.com/ipfs/bafkreids5nicikug7bmleipftmkud2v4detmwiipjru35m23jgv56ee2zq"
      , price = Nothing
      , owner = "0x1A22f8e327adD0320d7ea341dFE892e43bC60322"
      }
    , { network = "sepolia"
      , contractAddress = "0xa47d17727fDe3826d92A77BE2f83F6fb1d7254e8"
      , tokenId = "10"
      , title = "Spar"
      , description = "MS Paint 2023"
      , image = "https://cloudflare-ipfs.com/ipfs/bafkreigupts7gjtvnimkpv4vqskmgypennzqgiwuaqgyisgcsmeaxy6niy"
      , price = Nothing
      , owner = "0x1A22f8e327adD0320d7ea341dFE892e43bC60322"
      }
    ]
