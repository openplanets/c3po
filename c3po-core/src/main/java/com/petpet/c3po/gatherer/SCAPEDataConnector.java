package com.petpet.c3po.gatherer;

import com.petpet.c3po.api.gatherer.MetaDataGatherer;
import com.petpet.c3po.api.model.helper.MetadataStream;
import com.sun.jersey.api.client.Client;
import com.sun.jersey.api.client.config.ClientConfig;
import com.sun.jersey.api.client.Client;
import com.sun.jersey.api.client.WebResource;
import com.sun.jersey.api.client.config.ClientConfig;
import com.sun.jersey.api.client.config.DefaultClientConfig;
import com.sun.jersey.api.client.filter.HTTPBasicAuthFilter;

import java.io.InputStream;
import java.util.Map;
import java.util.concurrent.LinkedBlockingQueue;

/**
 * Created by artur on 9/4/2014.
 */
public class SCAPEDataConnector implements MetaDataGatherer{
    private final Client client;
    private final WebResource endpoint;

    @Override
    public void setConfig(Map<String, String> config) {

    }
    
    public SCAPEDataConnector(final String endpoint, final String user, final String password){
        ClientConfig cc = new DefaultClientConfig();

        this.client = Client.create(cc);
        this.client.addFilter(new HTTPBasicAuthFilter(user, password));
        this.endpoint = this.client.resource(endpoint);
    }

    public InputStream downloadFile(String identifier) throws RepositoryConnectorException{
        // /file/<entity-id>/<representation-id>/<file-id>/<version-id>
        try {

            String internalIdentifier = identifier.replaceFirst("([\\S]*/)?([^/]+/[^/]+/[^/]+)$", "$2");

            return endpoint.path("file/" + internalIdentifier).get(InputStream.class);
        } catch (Exception e) {
            throw new RepositoryConnectorException(e);
        }
    }

    @Override
    public MetadataStream getNext() {
        return null;
    }

    @Override
    public boolean hasNext() {
        return false;
    }

    @Override
    public LinkedBlockingQueue<MetadataStream> getQueue() {
        return null;
    }

    @Override
    public boolean isReady() {
        return false;
    }

    @Override
    public void run() {

    }
}
