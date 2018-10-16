#!/usr/bin/python3
import os, numpy as np

d2r = np.pi / 180,
r2d = 180 / np.pi

def quadkey_to_tile(quadkey):
    """Transform quadkey to tile coordinates"""
    tile_x, tile_y = (0, 0)
    level = len(quadkey)
    for i in range(level):
        bit = level - i
        mask = 1 << (bit - 1)
        if quadkey[level - bit] == '1':
            tile_x |= mask
        if quadkey[level - bit] == '2':
            tile_y |= mask
        if quadkey[level - bit] == '3':
            tile_x |= mask
            tile_y |= mask
    return [tile_x, tile_y, level]

def tile_to_bbox(tile):
    e = tile2lon(tile[0] + 1, tile[2])
    w = tile2lon(tile[0], tile[2])
    s = tile2lat(tile[1] + 1, tile[2])
    n = tile2lat(tile[1], tile[2])
    return [w, s, e, n]

def tile2lon(x, z) :
    return x / np.power(2, z) * 360 - 180

def tile2lat(y, z) :
    n = np.pi - 2 * np.pi * y / np.power(2, z)
    return r2d * np.arctan(0.5 * (np.exp(n) - np.exp(-n)))

zoomLevel = 3

QUADS = "QUAD_EXTRACTS"
BASEDIR  = "QUADS"

def pad0(string):
    string = "0" + string
    if len(string)<zoomLevel:
        return pad0(string)
    return string

extracts = []
for i in range(4**zoomLevel):
    quad = np.base_repr(i, base=4)
    if len(quad) < zoomLevel:
        quad = pad0(quad)
    bbox = tile_to_bbox(quadkey_to_tile(quad))
    extracts.append({
        "output": "quadkey_"+quad+".osh.pbf",
        "description" : "quadkey_"+quad,
        "bbox": ",".join( [str(e) for e in bbox] )
    })


for e in extracts[14:]:
    print("\n================================================\n")
    print("Going for ", e['output'])
    command = "mason_packages/.link/bin/osmium extract --set-bounds --with-history --overwrite --bbox={0} --verbose \
 -o {3}/{1} {2}".format(e['bbox'],e['output'],'history-latest.osm.pbf',QUADS)
    print(command)
    os.system(command)
    
    print("\nNow going for the full run!\n")
    
    command = "./run.sh {0}/{1} {2}/{3}".format(QUADS,e['output'],BASEDIR, e['output'][:-8])
    print(command)
    os.system(command)
    print()
