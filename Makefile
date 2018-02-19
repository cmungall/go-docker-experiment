IMG=solr:6

# ----------
# REPO SETUP
# ----------
# Note: these should only be need to be built if
#  - we upgrade solr version
#  - the schema changes
#  - we change the config in some other way
#
# otherwise, the content already checked into this repo should be sufficient
#
# NOTE: the current setup creates a core solr giving urls like http://localhost:8983/solr/solr/select?q=*:*
# which is a bit odd

seedconf: _seedconf inject-config

# see: https://github.com/docker-solr/docker-solr-examples/tree/master/schema-api
_seedconf:
	docker run --rm -d --name solr-initial -p 8983:8983 $(IMG) solr-precreate initial_core && \
	docker cp solr-initial:/opt/solr/server/solr/mycores/initial_core amigocore && \
	docker kill solr-initial

# TODO: use the same code as monarch; release it on mvn central
# NOTE: this is just for testing, we need the full set of schemas for a complete load!
# TODO: it looks like the owltools yaml2schema compiler isn't solr6 compatible.
#  For now use the hardcoded managed-schema file checked into this repo
managed-schema: ont-config.yaml
	owltools --solr-config $< --solr-schema-dump > $@

# insert the configs we care about into the generic config
inject-config: managed-schema
	cp managed-schema solrconfig.xml amigocore/conf/

# ----------
# DOCKER
# ----------

# TODO: publish
build-solr-image:
	docker build -t amigo-solr .

# TODO: publish
build-loader-image:
	cd load && docker build -t amigo-solr-loader .

# note: we don't need this as we use docker-compose,
# but this can be used for testing
test-run-solr:
	docker run -p 8983:8983 amigo-solr

# perform full load cycle - build images then use docker-compose to load.
# After loading, should be queryable: http://localhost:8983/solr/solr/select?q=*:*
# And index should be here: mydata/
load: clean build-solr-image build-loader-image _load
_load: clean
	docker-compose up &&\
	echo "check the ./mydata/ folder, and http://localhost:8983/solr/solr/select?q=*:*"

clean:
	test -d mydata && rm -rf mydata || echo "initial load"

# note: we don't need this as we use docker-compose,
# but this can be used for testing
test-load-without-docker:
	docker run owltools:solr6 owltools http://purl.obolibrary.org/obo/go/subsets/goslim_generic.obo \
--log-debug \
--solr-config ont-config.yaml \
 --silence-elk --reasoner elk \
--solr-url http://127.0.0.1:8983/solr/solr --solr-log /tmp/golr_timestamp.log  --solr-load-ontology


#x:
#	docker-compose cp golr:/opt/solr/server/solr/ data-dump
