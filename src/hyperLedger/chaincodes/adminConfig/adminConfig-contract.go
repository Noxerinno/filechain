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

type adminConfig struct {
	IpfsId         string `json:"IpfsId"` 
	AdminIpAddress string `json:"AdminIpAddress"`    
	SwarmKey       string `json:"SwarmKey"`
	ClusterSecret  string `json:"ClusterSecret"`
	ClusterPeerId  string `json:"ClusterPeerId"`
}
/*
func (t *SimpleContract) Init(ctx contractapi.TransactionContextInterface, state string) error {
	
	fmt.Println("helloBlock initialization")
	var err error
	fmt.Printf("State %s", state)
	// Write the initialized state to the ledger
	err = ctx.GetStub().PutState(state, []byte(state))
	if err != nil {
		return err
	}

	return nil
	
}

func (t *SimpleContract) Invoke(ctx contractapi.TransactionContextInterface, state string) error {

	var err error
	// Get the state from the ledger
	statebytes, err := ctx.GetStub().GetState(state)
	if err != nil {
		return fmt.Errorf("Cannot get state")
	}
	if statebytes == nil {
		return fmt.Errorf("No state found")
	}

	fmt.Printf("State %s", state)

	// Write the state back to the ledger
	err = ctx.GetStub().PutState(state, []byte(state))
	if err != nil {
		return err
	}

	return nil

}
*/

// Create adds a new key with value to the world state
func (sc *SimpleContract) Create(ctx contractapi.TransactionContextInterface, jsonString adminConfig) error {
    var err error

	adminConfig :=jsonString
	if adminConfig.IpfsId == ""{
		return fmt.Errorf("There is no IpfsId specified")
	}
	if adminConfig.AdminIpAddress == ""{
		return fmt.Errorf("There is no AdminIpAddress specified")
	}
	if adminConfig.SwarmKey == ""{
		return fmt.Errorf("There is no SwarmKey specified")
	}
	if adminConfig.ClusterSecret == ""{
		return fmt.Errorf("There is no ClusterSecret specified")
	}
	if adminConfig.ClusterPeerId == ""{
		return fmt.Errorf("There is no ClusterPeerId specified")
	}

	// ==== Check if adminConfig already exists ====
	adminConfigAsBytes, err := ctx.GetStub().GetState(adminConfig.IpfsId)
	if err != nil {
		return fmt.Errorf("Failed to get adminConfig: " + err.Error())
	} else if adminConfigAsBytes != nil {
		fmt.Println("This adminConfig already exists: " + adminConfig.IpfsId)
		return fmt.Errorf("This adminConfig already exists: " + adminConfig.IpfsId)
	}

    // ==== Create adminConfig object and marshal to JSON ====

	adminConfigJSONasBytes, err := json.Marshal(adminConfig)
	if err != nil {
		return fmt.Errorf(err.Error())
	}
	//Alternatively, build the adminConfig json string manually if you don't want to use struct marshalling
	//adminConfigJSONasString := `{"IpfsId":"` + IpfsId + `",  "AdminIpAddress": "` + AdminIpAddress + `", "SwarmKey": "` + SwarmKey + `", "ClusterSecret": "` + ClusterSecret + `", "ClusterPeerId" : "` + ClusterPeerId + `"}`
	//adminConfigJSONasBytes := []byte(str)

	// === Save adminConfig to state ===
	err = ctx.GetStub().PutState(adminConfig.IpfsId, adminConfigJSONasBytes)
	if err != nil {
		return fmt.Errorf(err.Error())
	}

	// ==== adminConfig saved and indexed. Return success ====
	fmt.Println("- end init adminConfig")
	return nil
}

// Update changes the value with key in the world state
func (sc *SimpleContract) Update(ctx contractapi.TransactionContextInterface, key string, jsonString adminConfig) error {
    

    existing, err := ctx.GetStub().GetState(key)

    if err != nil {
        return errors.New("Unable to interact with world state")
    }

    if existing == nil {
        return fmt.Errorf("Cannot update world state pair with key %s. Does not exist", key)
	}
	
	adminConfig :=jsonString
	if adminConfig.IpfsId == ""{
		return fmt.Errorf("There is no IpfsId specified")
	}
	if adminConfig.AdminIpAddress == ""{
		return fmt.Errorf("There is no AdminIpAddress specified")
	}
	if adminConfig.SwarmKey == ""{
		return fmt.Errorf("There is no SwarmKey specified")
	}
	if adminConfig.ClusterSecret == ""{
		return fmt.Errorf("There is no ClusterSecret specified")
	}
	if adminConfig.ClusterPeerId == ""{
		return fmt.Errorf("There is no ClusterPeerId specified")
	}

    if key!=adminConfig.IpfsId{
        return fmt.Errorf("Cannot change key value in parameters. Current key is %s", key) 
    }

    adminConfigJSONasBytes, err := json.Marshal(adminConfig)
	if err != nil {
		return fmt.Errorf(err.Error())
	}

    err = ctx.GetStub().PutState(key, adminConfigJSONasBytes)

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
func (sc *SimpleContract) ReadAll(ctx contractapi.TransactionContextInterface) ([]adminConfig, error) {
    startKey := ""
	endKey := ""

	resultsIterator, err := ctx.GetStub().GetStateByRange(startKey, endKey)

	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	results := []adminConfig{}

	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()

		if err != nil {
			return nil, err
		}

		adminConfig := new(adminConfig)
        _ = json.Unmarshal(queryResponse.Value, adminConfig)
        
		results = append(results, *adminConfig)
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
