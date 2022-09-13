# LDC

Dockerfile for building the LLVM D Compiler.

## Building

Run the below command to build image.

```bash
docker build . -f ldc2.dockerfile
```

## Docker Registry

Instead of building, you can pull the image from the docker registry

```bash
docker pull cshore2/ldc2
```