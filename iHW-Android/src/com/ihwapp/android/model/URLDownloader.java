package com.ihwapp.android.model;

import java.io.*;
import java.net.*;

import com.ihwapp.android.R;

import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnCancelListener;
import android.os.AsyncTask;
import android.util.Log;

class URLDownloader extends AsyncTask<String, Void, String> {

	private ProgressDialog progressDialog;
	private OnCompleteListener ocl;
	private OnErrorListener oel;
	private boolean error = false;
	private Exception exception = null;
	private boolean cancelable;

	public URLDownloader(Context ctx, boolean cancelable) {
		progressDialog = new ProgressDialog(ctx, R.style.PopupTheme);
		this.ocl = null;
		this.oel = null;
		this.cancelable = cancelable;
	}
	
	public void setOnCompleteListener(OnCompleteListener ocl) {
		this.ocl = ocl;
	}
	
	public void setOnErrorListener(OnErrorListener oel) {
		this.oel = oel;
	}

	protected void onPreExecute() {
		progressDialog.setMessage("Downloading holidays, special schedules, etc.");
		progressDialog.setCancelable(cancelable);
		progressDialog.setCanceledOnTouchOutside(cancelable);
		progressDialog.show();
		progressDialog.setOnCancelListener(new OnCancelListener() {
			public void onCancel(DialogInterface arg0) {
				URLDownloader.this.cancel(true);
			}
		});
		Log.d("iHW", "preparing to download");
	}

	@Override
	protected String doInBackground(String... params) {
		Log.d("iHW", "downloading from url: " + params[0]);
		HttpURLConnection urlConnection = null;
		String result = null;
		try {
			URL url = new URL(params[0]);
			urlConnection = (HttpURLConnection) url.openConnection();
			InputStream in = new BufferedInputStream(urlConnection.getInputStream());
			InputStreamReader ir = new InputStreamReader(in);
			StringBuilder sb = new StringBuilder();
			BufferedReader br = new BufferedReader(ir);
			String line = br.readLine();
			while(line != null) {
			    sb.append(line);
			    line = br.readLine();
			}
			result = sb.toString();
		} catch (Exception e) {
			error = true;
			exception = e;
		} finally {
			if (urlConnection != null) urlConnection.disconnect();
		}
		Log.d("iHW", "download finished");
		return result;
		/*
    	ArrayList<NameValuePair> param = new ArrayList<NameValuePair>();
        try {
        	// Set up HTTP post
            // HttpClient is more then less deprecated. Need to change to URLConnection
            HttpClient httpClient = new DefaultHttpClient();
            HttpPost httpPost = new HttpPost(url_select);
            httpPost.setEntity(new UrlEncodedFormEntity(param));
            HttpResponse httpResponse = httpClient.execute(httpPost);
            HttpEntity httpEntity = httpResponse.getEntity();
            // Read content & Log
            inputStream = httpEntity.getContent();
        } catch (UnsupportedEncodingException e1) {
            Log.e("UnsupportedEncodingException", e1.toString());
            e1.printStackTrace();
        } catch (ClientProtocolException e2) {
            Log.e("ClientProtocolException", e2.toString());
            e2.printStackTrace();
        } catch (IllegalStateException e3) {
            Log.e("IllegalStateException", e3.toString());
            e3.printStackTrace();
        } catch (IOException e4) {
            Log.e("IOException", e4.toString());
            e4.printStackTrace();
        }
        // Convert response to string using String Builder
        try {
            BufferedReader bReader = new BufferedReader(new InputStreamReader(inputStream, "iso-8859-1"), 8);
            StringBuilder sBuilder = new StringBuilder();
            String line = null;
            while ((line = bReader.readLine()) != null) {
                sBuilder.append(line + "\n");
            }
            inputStream.close();
            result = sBuilder.toString();
        } catch (Exception e) {
            Log.e("StringBuilding & BufferedReader", "Error converting result " + e.toString());
        }*/
	}
	@Override
	protected void onPostExecute(String result) {
		Log.d("iHW", "post execute - error: " + error);
		//JSONArray jArray = new JSONArray(result);
		this.progressDialog.dismiss();
		if (error && oel != null) oel.onDownloadError(exception); 
		if (!error && ocl != null) ocl.onDownloadComplete(result);
	}
	
	public interface OnCompleteListener {
		public void onDownloadComplete(String result);
	}
	
	public interface OnErrorListener {
		public void onDownloadError(Exception e);
	}
}