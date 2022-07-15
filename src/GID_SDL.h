#ifndef ANTIMONY_III_GID_SDL_H
#define ANTIMONY_III_GID_SDL_H

#define GID(i,f)


#if __has_include(<SDL2/SDL.h>)
    #define GID_SDL(f) <SDL2/f>
#elif __has_include(<SDL.h>)
    #define GID_SDL(f) <f>
#endif

#endif //ANTIMONY_III_GID_SDL_H
