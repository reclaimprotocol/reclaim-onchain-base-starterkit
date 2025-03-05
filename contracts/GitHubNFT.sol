// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

// Structs for claim and proof information
struct ClaimInfo {
    string provider;
    string parameters;
    string context;
}

struct Claim {
    bytes32 identifier;
    address owner;
    uint32 timestampS;
    uint32 epoch;
}

struct SignedClaim {
    Claim claim;
    bytes[] signatures;
}

struct Proof {
    ClaimInfo claimInfo;
    SignedClaim signedClaim;
}

// Interface for ReclaimVerifier
interface IReclaimVerifier {
    function verifyProof(Proof memory proof) external view;
}

contract GitHubNFT is ERC721URIStorage {
    address public reclaimAddress;
    uint256 public nextTokenId;
    mapping(string => bool) public hasMinted;

    constructor(address _reclaimAddress) ERC721("GitHubNFT", "GHNFT") {
        reclaimAddress = _reclaimAddress;
    }

    function mint(Proof memory proof) public {
        try IReclaimVerifier(reclaimAddress).verifyProof(proof) {
            string memory context = proof.claimInfo.context;
            string memory username = getFieldFromContext(context, '"username":"');
            require(bytes(username).length > 0, "Username is missing");
            require(!hasMinted[username], "NFT already minted for this user");
            hasMinted[username] = true;

            uint256 tokenId = nextTokenId++;
            _safeMint(msg.sender, tokenId);
            _setTokenURI(tokenId, generateTokenURI(username));
        } catch {
            revert("Proof verification failed");
        }
    }

    function generateTokenURI(string memory username) internal pure returns (string memory) {
        string memory svg = generateSVG(username);
        string memory metadata = string(abi.encodePacked(
            '{"name":"GitHub NFT #', username, '",',
            '"description":"An NFT based on GitHub username proof",',
            '"image":"data:image/svg+xml;base64,', Base64.encode(bytes(svg)), '"}'
        ));
        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(metadata))));
    }

    function generateSVG(string memory username) internal pure returns (string memory) {
        return string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" width="300" height="300">',
                '<rect width="100%" height="100%" fill="#f4f4f4"/>',
                '<text x="50%" y="50%" font-size="20" text-anchor="middle" fill="#333">',
                username,
                '</text></svg>'
            )
        );
    }

    function getFieldFromContext(string memory _data, string memory target) internal pure returns (string memory) {
        bytes memory dataBytes = bytes(_data);
        bytes memory targetBytes = bytes(target);
        
        require(dataBytes.length >= targetBytes.length, "Target is longer than data");
        
        uint256 start = 0;
        bool foundStart = false;
        
        for (uint256 i = 0; i <= dataBytes.length - targetBytes.length; i++) {
            bool isMatch = true;
            for (uint256 j = 0; j < targetBytes.length && isMatch; j++) {
                if (dataBytes[i + j] != targetBytes[j]) {
                    isMatch = false;
                }
            }
            if (isMatch) {
                start = i + targetBytes.length;
                foundStart = true;
                break;
            }
        }

        if (!foundStart) {
            return "";
        }

        uint256 end = start;
        while (end < dataBytes.length && !(dataBytes[end] == '"' && (end == 0 || dataBytes[end - 1] != '\\'))) {
            end++;
        }

        if (end <= start) {
            return "";
        }

        bytes memory resultBytes = new bytes(end - start);
        for (uint256 i = start; i < end; i++) {
            resultBytes[i - start] = dataBytes[i];
        }

        return string(resultBytes);
    }
}
