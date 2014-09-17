package com.petpet.c3po.gatherer;

import eu.scape_project.model.Identifier;
import eu.scape_project.model.Representation;
import eu.scape_project.model.TestUtil;
import junit.framework.TestCase;
import eu.scape_project.model.IntellectualEntity;
import eu.scape_project.util.ScapeMarshaller;
import org.apache.commons.io.IOUtils;
import org.apache.http.HttpEntity;
import org.apache.http.client.HttpClient;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.InputStreamEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;
import org.apache.http.entity.ContentType;

import javax.xml.bind.JAXBException;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.net.ConnectException;
import java.util.Arrays;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import com.sun.jersey.api.client.Client;
import com.sun.jersey.api.client.WebResource;
import com.sun.jersey.api.client.config.ClientConfig;
import com.sun.jersey.api.client.config.DefaultClientConfig;
import com.sun.jersey.api.client.filter.HTTPBasicAuthFilter;

public class SCAPEDataConnectorTest extends TestCase {

    private Client client;
    private WebResource endpoint;



    public void setUp() throws Exception {
        super.setUp();





    }

    public void testSetConfig() throws Exception {

    }

    public void testGetNext() throws Exception {

    }

    public void testHasNext() throws Exception {

    }

    public void testGetQueue() throws Exception {

    }

    public void testIsReady() throws Exception {

    }

    public void testRun() throws Exception {


    }


}