/*
Serve is a very simple static file server in go
Usage:
	-p="8100": port to serve on
	-d=".":    the directory of static files to host
*/
package main

import (
	"flag"
	"log"
	"net/http"
	"os"
)

func dontListDirs(dir string, h http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		path := dir + "/" + r.URL.Path
		stat, err := os.Stat(path)
		if err != nil || stat.IsDir() {
			http.NotFound(w, r)
		} else {
			h.ServeHTTP(w, r)
		}
	})
}

func main() {
	port := flag.String("p", "8100", "port to serve on")
	directory := flag.String("d", ".", "the directory of static file to host")
	flag.Parse()
	
	http.Handle("/", dontListDirs(*directory, http.FileServer(http.Dir(*directory))))
	//http.Handle("/", http.FileServer(http.Dir(*directory)))

	log.Printf("Serving %s on HTTP port: %s\n", *directory, *port)
	log.Fatal(http.ListenAndServe(":"+*port, nil))
}
