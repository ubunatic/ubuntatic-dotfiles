#!/usr/bin/env python
import sys, re, logging, random

logging.basicConfig(level=logging.INFO)
log = logging.getLogger('passwd_gen')

vows = "aeiou"
xows = "034"
cons = "bcdfghjklmnpqrstvwxyz"
xons = "0123456789"

vowels = list(3 * vows + xows)
consos = list(2 * cons + xons)
seps   = list("-")
rand   = random.SystemRandom()

def rand_char(chars): return chars[rand.randrange(len(chars))]

def get_word(size=5):
    i = 0
    while i < size:
        if i < size: yield rand_char(vowels); i += 1
        if i < size: yield rand_char(consos); i += 1

def get_passwd(size=30):
    result = ""
    while len(re.findall(r'[0-9]', result)) < 1: # ensure there is at least one number inside
        p = []
        while len(p) < size:
            if len(p) > 0: p.append(rand_char(seps)) # add a separartor between words
            wl = rand.randrange(3,7)      # try to add a word with 3 - 7 characters
            if len(p) + wl + 4 > size:    # but if we are too close to the target size
                wl = size - len(p)        # we try to extend to the reach the size
                if wl > 7: wl = 3         # or spilt up again

            word = list(get_word(wl))     # then generate a word
            p.extend(word)                # and add it

        result = ''.join(p) 

    return result

if len(sys.argv) > 1: size = int(sys.argv[1])
else:                 size = 30

print ''.join(get_passwd(size))

