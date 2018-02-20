FROM cmungall/owltools:solr6

RUN echo hi
RUN curl -L https://raw.githubusercontent.com/geneontology/amigo/master/metadata/ont-config.yaml > ont-config.yaml
RUN echo hi

## TODO: a more resilient way of waiting for the solr server to start. This should probably be built into owltools. For now sleep=3 seems fine.
## TODO: load additional stuff; solr-load-ontology does not appear to work - difference in schema?
## TODO: configuration should not be baked into Dockerfile - instead pull from a conf file.
CMD sleep 3 && owltools  \
http://purl.obolibrary.org/obo/go/subsets/goslim_generic.obo \
--solr-config ont-config.yaml \
--merge-support-ontologies --merge-imports-closure --remove-subset-entities upperlevel --remove-disjoints --silence-elk --reasoner elk --solr-taxon-subset-name amigo_grouping_subset --solr-eco-subset-name go_groupings \
--solr-url http://golr:8983/solr/solr --solr-log /tmp/golr_timestamp.log  --solr-load-ontology-general
