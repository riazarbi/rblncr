from setuptools import setup, find_packages

setup(
    name='rebalancer',
    version='0.1',
    packages=find_packages(),
    install_requires=[
        'requests',
        'pandas',
        'python-dateutil'
    ],
    # Include additional files into the package
    package_data={
        # If any package contains *.txt or *.rst files, include them:
        '': ['*.txt', '*.rst'],
        'rebalancer': ['*.md'],
    },
    author="Your Name",
    author_email="your.email@example.com",
    description="A package for financial portfolio rebalancing",
    keywords="portfolio rebalancing finance",
    url="http://example.com/rebalancer",   # project home page, if any
)
