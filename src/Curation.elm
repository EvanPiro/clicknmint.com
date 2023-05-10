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
