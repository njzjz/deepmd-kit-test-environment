import os
from setuptools import setup
from packaging.specifiers import SpecifierSet

require = [
    # setup requirements
    "setuptools",
    "setuptools_scm",
    "wheel",
    "scikit-build",
    "cmake",
    "ninja",
    "m2r",
    # run time requirements
    "numpy",
    "scipy",
    "pyyaml",
    "dargs >= 0.2.6",
    "python-hostlist >= 1.21",
    'typing_extensions; python_version < "3.7"',
    "h5py",
    "wcmatch",
    # test requirements
    "dpdata>=0.1.9",
    "ase",
    "pytest",
    "pytest-cov",
    "pytest-sugar",
    'protobuf < 3.20',
]
tf_version = os.environ.get("TENSORFLOW_VERSION", "")

if tf_version == "":
    require.append("tensorflow-cpu")
elif tf_version in SpecifierSet("<1.15") or tf_version in SpecifierSet(">=2.0,<2.1"):
    require.append(f"tensorflow=={tf_version}.*")
else:
    require.append(f"tensorflow-cpu=={tf_version}.*")

gcc_version = os.environ.get("GCC_VERSION", "")
if gcc_version in SpecifierSet(">=4.9") and (tf_version in SpecifierSet(">=1.15") or tf_version == ""):
    mpi = ["horovod", "mpi4py"]
else:
    mpi = []

setup(name="deepmd-kit-test-environment", install_requires=require, extras_require={"mpi": mpi})

