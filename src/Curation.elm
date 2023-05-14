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
    [ { network = "goerli"
      , contractAddress = "0x25b6364A5979e0e7C2ca3124d3b5d0A365EF1259"
      , tokenId = "0"
      , title = "Piano"
      , description = "MS Paint 2023"
      , image = "https://cloudflare-ipfs.com/ipfs/bafkreiau7qvi4zkai54e4kpahbkwcdm46bzrppiz6yqqex3aqla4olzbzm"
      }
    , { network = "sepolia"
      , contractAddress = "0xa47d17727fDe3826d92A77BE2f83F6fb1d7254e8"
      , tokenId = "19"
      , title = "Candor"
      , description = "MS Paint 2023"
      , image = "https://cloudflare-ipfs.com/ipfs/bafkreiajbtv5l477zvdqy4ye5u5glh7sgf4ij35uzolkyaotjk76mtacum"
      }
    , { network = "sepolia"
      , contractAddress = "0xa47d17727fDe3826d92A77BE2f83F6fb1d7254e8"
      , tokenId = "18"
      , title = "Cadence"
      , description = "MS Paint 2023"
      , image = "https://cloudflare-ipfs.com/ipfs/bafkreif2kcnlsa74d4us33wngjnmm6ae6cc52sqa4l4zpoxrzaj7uqj4n4"
      }
    , { network = "sepolia"
      , contractAddress = "0xa47d17727fDe3826d92A77BE2f83F6fb1d7254e8"
      , tokenId = "17"
      , title = "Disambuation"
      , description = "MS Paint 2023"
      , image = "https://cloudflare-ipfs.com/ipfs/bafkreiaquiyls7oaag5hubgdjckhusry2asm5ipstepeiclpv4uftnbtca"
      }
    , { network = "sepolia"
      , contractAddress = "0xa47d17727fDe3826d92A77BE2f83F6fb1d7254e8"
      , tokenId = "16"
      , title = "Tequila Sunrise"
      , description = "MS Paint 2023"
      , image = "https://cloudflare-ipfs.com/ipfs/bafkreigqhwytpndh5rttb4eyio6axsjiuuyz5tqp354dielzvg6223tpyi"
      }
    , { network = "sepolia"
      , contractAddress = "0xa47d17727fDe3826d92A77BE2f83F6fb1d7254e8"
      , tokenId = "15"
      , title = "Horse Crow"
      , description = "MS Paint 2023"
      , image = "https://cloudflare-ipfs.com/ipfs/bafkreigk6qqdlmbovkatj2smw5dkx7glq4ic5w56ydg32wqazwmf66u56i"
      }
    , { network = "sepolia"
      , contractAddress = "0xa47d17727fDe3826d92A77BE2f83F6fb1d7254e8"
      , tokenId = "11"
      , title = "Vessel"
      , description = "MS Paint 2023"
      , image = "https://cloudflare-ipfs.com/ipfs/bafkreifmiiuorrq3rctrkvsx4hhvk3lcztgca6654n4ukhpt4dndfgg3na"
      }
    , { network = "sepolia"
      , contractAddress = "0xa47d17727fDe3826d92A77BE2f83F6fb1d7254e8"
      , tokenId = "6"
      , title = "Figures"
      , description = "MS Paint 2023"
      , image = "https://cloudflare-ipfs.com/ipfs/bafkreid4novsnog4puxw5yhtanm33kfkszocfic3xqum3mmdglvawo6z54"
      }
    , { network = "sepolia"
      , contractAddress = "0xa47d17727fDe3826d92A77BE2f83F6fb1d7254e8"
      , tokenId = "7"
      , title = "Orbs"
      , description = "MS Paint 2023"
      , image = "https://cloudflare-ipfs.com/ipfs/bafkreieob5vjosghtgtqmcfjosw7mgi3n2rcwkz23xchfwttmuxo6yj2k4"
      }
    , { network = "sepolia"
      , contractAddress = "0xa47d17727fDe3826d92A77BE2f83F6fb1d7254e8"
      , tokenId = "8"
      , title = "The Golden Ratio"
      , description = "MS Paint 2023"
      , image = "https://cloudflare-ipfs.com/ipfs/bafkreids5nicikug7bmleipftmkud2v4detmwiipjru35m23jgv56ee2zq"
      }
    , { network = "sepolia"
      , contractAddress = "0xa47d17727fDe3826d92A77BE2f83F6fb1d7254e8"
      , tokenId = "10"
      , title = "Spar"
      , description = "MS Paint 2023"
      , image = "https://cloudflare-ipfs.com/ipfs/bafkreigupts7gjtvnimkpv4vqskmgypennzqgiwuaqgyisgcsmeaxy6niy"
      }
    ]
