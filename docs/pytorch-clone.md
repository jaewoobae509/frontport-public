# Include pytorch as a submodule

## Clone the Repository (already done)

To include pytorch as a submodule, run the following command:

```bash
git submodule add https://github.com/pytorch/pytorch.git pytorch
```

This will add the pytorch repository as a submodule in the `pytorch` directory.

## Checkout the Specific Commit (need to be done after cloning)
```bash
cd pytorch
git fetch
git checkout a8d6afb511a69687bbb2b7e88a3cf67917e1697e
```

`a8d6afb511a69687bbb2b7e88a3cf67917e1697e` is the commit hash of the specific commit of pytorch `v2.5.1`.


