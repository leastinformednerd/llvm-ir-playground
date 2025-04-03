# LLVM IR Playground
To teach myself the LLVM IR so that I'm better able to write a compiler targetting it I've been playing around with handwriting programs in it.

(Hello World) [./hello_world.ll] is a basic program used to get myself used to writing basic control flow and using SSA form

(Iterator) [iterator.ll] is an implementation of virtual method dispatch. I feel like it contains an extra unnecessary indirection, but I haven't looked too hard. Ironically I think writing the codegen for this section will be easier than writing it by hand was, since I'll have actual types to work with instead of opaque `ptr` types
