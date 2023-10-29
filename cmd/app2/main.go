package main

import (
	"log"

	"github.com/Panzhongsheng/spiritual-practice-of-Go/pkg/version"
)

func main() {
	log.Printf("version: %s\n", version.Version)
}
