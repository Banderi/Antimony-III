#include "antimony.h"
#include "core/events.h"

#include <iostream>

static void Setup() {
    std::cout << "Hello, World!" << std::endl;
    getchar();

    // setup SDL
    // setup logging
};

static bool QuitRequest() {
    return true;
}
static int Cleanup() {
    return 0; // default
}
int Antimony::Start() {
    Setup(); // setup Antimony backend
    do { // main Antimony process loop
        UpdateEvents(); //
    } while (!QuitRequest());
    return Cleanup(); // cleanup Antimony and shutdown process
}