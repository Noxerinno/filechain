// Copyright [2020] [Frantz Darbon, Gilles Seghaier, Johan Tombre, Frédéric Vaz]

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//     https://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// ==============================================================================

package main

import (
    "errors"
    "fmt"
	"encoding/json"

    "github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// SimpleContract contract for handling writing and reading from the world state
type SimpleContract struct {
    contractapi.Contract
}

type Shard struct{
	Hash string `json:"hash"`
	Position int `json:"position"`
}

type File struct {
	MainHash  string `json:"main_hash"` 
	Filename  string `json:"filename"`    
	Timestamp int `json:"timestamp"`
	MimeType  string `json:"mime-type"`
	Shards    []Shard `json:"shards"`
}

// Create adds a new key with value to the world state
func (sc *SimpleContract) Create(ctx contractapi.TransactionContextInterface, jsonString File) error {
    var err error

	fileData :=jsonString
	if fileData.MainHash == ""{
		return fmt.Errorf("There is no MainHash specified")
	}
	if fileData.Filename == ""{
		return fmt.Errorf("There is no Filename specified")
	}
	if fileData.Timestamp == 0{
		return fmt.Errorf("There is no Timestamp specified")
	}
	if fileData.MimeType == ""{
		return fmt.Errorf("There is no MimeType specified")
	}
	if len(fileData.Shards) == 0{
		return fmt.Errorf("There are no Shards specified")
	}
	for _, element := range fileData.Shards{
		if element.Hash == ""{
			return fmt.Errorf("There is no Hash specified for this shard")
		}
		if element.Hash == ""{
			return fmt.Errorf("There is no Position specified for this shard")
		}
	}

	// ==== Check if File already exists ====
	fileDataAsBytes, err := ctx.GetStub().GetState(fileData.MainHash)
	if err != nil {
		return fmt.Errorf("Failed to get fileData: " + err.Error())
	} else if fileDataAsBytes != nil {
		fmt.Println("This fileData already exists: " + fileData.MainHash)
		return fmt.Errorf("This fileData already exists: " + fileData.MainHash)
	}

    // ==== Create fileData object and marshal to JSON ====

	fileDataJSONasBytes, err := json.Marshal(fileData)
	if err != nil {
		return fmt.Errorf(err.Error())
	}

	// === Save fileData to state ===
	err = ctx.GetStub().PutState(fileData.MainHash, fileDataJSONasBytes)
	if err != nil {
		return fmt.Errorf(err.Error())
	}

	// ==== fileData saved and indexed. Return success ====
	fmt.Println("- end init fileData")
	return nil
}

// Update changes the value with key in the world state
func (sc *SimpleContract) Update(ctx contractapi.TransactionContextInterface, key string, jsonString File) error {
    

	existing, err := ctx.GetStub().GetState(key)
	
	if err != nil {
        return errors.New("Unable to interact with world state")
    }

    if existing == nil {
        return fmt.Errorf("Cannot update world state pair with key %s. Does not exist", key)
	}

    fileData :=jsonString
	if fileData.MainHash == ""{
		return fmt.Errorf("There is no MainHash specified")
	}
	if fileData.Filename == ""{
		return fmt.Errorf("There is no Filename specified")
	}
	if fileData.Timestamp == 0{
		return fmt.Errorf("There is no Timestamp specified")
	}
	if fileData.MimeType == ""{
		return fmt.Errorf("There is no MimeType specified")
	}
	if len(fileData.Shards) == 0{
		return fmt.Errorf("There are no Shards specified")
	}
	for _, element := range fileData.Shards{
		if element.Hash == ""{
			return fmt.Errorf("There is no Hash specified for this shard")
		}
		if element.Hash == ""{
			return fmt.Errorf("There is no Position specified for this shard")
		}
	}

    if key!=fileData.MainHash{
        return fmt.Errorf("Cannot change key value in parameters. Current key is %s", key) 
    }

    fileDataJSONasBytes, err := json.Marshal(fileData)
	if err != nil {
		return fmt.Errorf(err.Error())
	}

    err = ctx.GetStub().PutState(key, fileDataJSONasBytes)

    if err != nil {
        return errors.New("Unable to interact with world state")
    }

    return nil
}

// Read returns the value at key in the world state
func (sc *SimpleContract) Read(ctx contractapi.TransactionContextInterface, key string) (string, error) {
    existing, err := ctx.GetStub().GetState(key)

    if err != nil {
        return "", errors.New("Unable to interact with world state")
    }

    if existing == nil {
        return "", fmt.Errorf("Cannot read world state pair with key %s. Does not exist", key)
    }

    return string(existing), nil
}

// ReadAll returns all the value in the world state
func (sc *SimpleContract) ReadAll(ctx contractapi.TransactionContextInterface) ([]File, error) {
    startKey := ""
	endKey := ""

	resultsIterator, err := ctx.GetStub().GetStateByRange(startKey, endKey)

	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	results := []File{}

	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()

		if err != nil {
			return nil, err
		}

		fileData := new(File)
        _ = json.Unmarshal(queryResponse.Value, fileData)
        
		results = append(results, *fileData)
	}

	return results, nil
}

func (sc *SimpleContract) Delete(ctx contractapi.TransactionContextInterface, key string) error {
	

	existing, err := ctx.GetStub().GetState(key)

    if err != nil {
        return errors.New("Unable to interact with world state")
    }

    if existing == nil {
        return fmt.Errorf("Cannot read world state pair with key %s. Does not exist", key)
    }

	// Delete the key from the state in ledger
	err = ctx.GetStub().DelState(key)
	if err != nil {
		return fmt.Errorf("Failed to delete state")
	}

	return nil
}
