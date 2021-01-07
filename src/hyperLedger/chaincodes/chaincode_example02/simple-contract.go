package main

import (
    "errors"
    "fmt"

    "github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// SimpleContract contract for handling writing and reading from the world state
type SimpleContract struct {
    contractapi.Contract
}

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


// Create adds a new key with value to the world state
func (sc *SimpleContract) Create(ctx contractapi.TransactionContextInterface, key string, value string) error {
    existing, err := ctx.GetStub().GetState(key)

    if err != nil {
        return errors.New("Unable to interact with world state")
    }

    if existing != nil {
        return fmt.Errorf("Cannot create world state pair with key %s. Already exists", key)
    }

    err = ctx.GetStub().PutState(key, []byte(value))

    if err != nil {
        return errors.New("Unable to interact with world state")
    }

    return nil
}

// Update changes the value with key in the world state
func (sc *SimpleContract) Update(ctx contractapi.TransactionContextInterface, key string, value string) error {
    existing, err := ctx.GetStub().GetState(key)

    if err != nil {
        return errors.New("Unable to interact with world state")
    }

    if existing == nil {
        return fmt.Errorf("Cannot update world state pair with key %s. Does not exist", key)
    }

    err = ctx.GetStub().PutState(key, []byte(value))

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
