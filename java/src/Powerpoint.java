import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import java.util.Scanner;
import java.util.List;
import org.apache.commons.io.IOUtils;

import java.awt.Color;

import com.google.gson.Gson;

import org.apache.poi.xslf.usermodel.SlideLayout;
import org.apache.poi.xslf.usermodel.XMLSlideShow;
import org.apache.poi.xslf.usermodel.XSLFPictureData;
import org.apache.poi.xslf.usermodel.XSLFPictureShape;
import org.apache.poi.xslf.usermodel.XSLFSlide;
import org.apache.poi.xslf.usermodel.XSLFSlideLayout;
import org.apache.poi.xslf.usermodel.XSLFSlideMaster;
import org.apache.poi.xslf.usermodel.XSLFTextBox;
import org.apache.poi.xslf.usermodel.XSLFTextParagraph;
import org.apache.poi.xslf.usermodel.XSLFTextRun;
import org.apache.poi.xslf.usermodel.XSLFTextShape;
import org.apache.poi.xslf.usermodel.TextAlign;
import org.apache.poi.xslf.usermodel.TextAutofit;


// For reference:
// POI - Apache OpenOffice API
// http://poi.apache.org/slideshow/xslf-cookbook.html
// http://poi.apache.org/apidocs/index.html
// GSON - Google JSON
// https://sites.google.com/site/gson/gson-user-guide#TOC-Using-Gson
// http://google-gson.googlecode.com/svn/trunk/gson/docs/javadocs/index.html

// For developer debugging statements, you can use:
// System.err.println(message);
// (since we're using System.out for the data stream)

// This reads a series of JSON objects from STDIN
/*
  CollectionData object example (one per export)
  {
    "collectionName":"The Collection Title",
    "description":["First description element","Another Description","And so on..."],
    "imageCount":no_of_slide_images
    "pptExportFile":"/local/server/path/to/ouput.pptx"
  }

  ImageData object example (one per each image in exported collection)
  {
    "title":"Image title from image metadata",
    "creator":["Photographer/Painter/Artists/Architect name","Can be multiple... or empty"],
    "date":["Creation_date from metadata","Could be multiple... or empty"],
    "description":["First description element","Another Description","Could be multiple... or empty"],
    "imagePath":"/local/server/path/to/image",
    "x":left-offset, y":top-offest, "width": image-width, "height": image-height} // use to center image on a 720 x 540 slide
  }
*/

public class Powerpoint {

  // Prefix your error message with this string
  // so that the ruby code knows it's an error.
  private static final String ERROR = "ERROR: ";

    static class CollectionData {
  	  public String collectionTitle;
  	  public String collectionType;
  	  public String creator;
  	  public String uri;
  	  public String[] description;

  	  public int imageCount;
      public String pptExportFile;

  	  public CollectionData() {
  	    // no-args constructor
  	  }
  	}

    static class ImageData {
  	  public String   title;
  	  public String[] creator;
  	  public String[] description;
  	  public String[] date;

      public String imagePath;
      public int x;
      public int y;
      public int height;
      public int width;

      public ImageData() {
        // no-args constructor
      }
    }

  public static void main(String[] args) {
    XMLSlideShow ppt = new XMLSlideShow();

    // Collect data from the ruby process and use
    // it to generate the powerpoint file.
    Scanner scan = new Scanner(System.in);

    String collection_json = scan.nextLine();
    Gson gson = new Gson();
    CollectionData collection = gson.fromJson(collection_json, CollectionData.class);

    addTitleSlide(ppt, collection);

    int numberOfImageSlides = collection.imageCount;
    for(int i=0; i<numberOfImageSlides; i++) {
      String image_json = scan.nextLine();
      ImageData img = gson.fromJson(image_json, ImageData.class);

      try {
        addMetadataSlide(ppt, img);
        addImageSlide(ppt, img);
      } catch(FileNotFoundException ex) {
        System.out.println(ERROR + ex.getMessage());
        return;
      } catch(IOException ex) {
        System.out.println(ERROR + ex.getMessage());
        return;
      }
    }

    String outputFileName = collection.pptExportFile;
    System.out.println(writePptFile(ppt, outputFileName));
  }

  private static void addTitleSlide(XMLSlideShow ppt, CollectionData collection) {

    XSLFSlideMaster defaultMaster = ppt.getSlideMasters()[0];
    XSLFSlideLayout titleBodyLayout = defaultMaster.getLayout(SlideLayout.TITLE_AND_CONTENT);
    XSLFSlide slide = ppt.createSlide(titleBodyLayout);
    XSLFTextShape[] placeholders = slide.getPlaceholders();

    XSLFTextShape titleBlock = placeholders[0];
    addTitle(titleBlock, collection.collectionTitle);

    // Replace main body placeholder with our description data
    XSLFTextShape descriptionBlock = placeholders[1];
    descriptionBlock.clearText();
    descriptionBlock.setTextAutofit(TextAutofit.NORMAL);

    XSLFTextParagraph para;
    XSLFTextRun r1;
    for(int j=0; j<collection.description.length; j++) {
      para = descriptionBlock.addNewTextParagraph();
      para.setLevel(0);
      para.setBullet(true);
      para.setBulletFontColor(Color.BLACK);

      r1 = para.addNewTextRun();
      r1.setText(collection.description[j]);
      r1.setFontSize(30);
    }

    resizeBlock(descriptionBlock);
  }

  private static void addMetadataSlide(XMLSlideShow ppt, ImageData image) {

    XSLFSlideMaster defaultMaster = ppt.getSlideMasters()[0];
    XSLFSlideLayout titleBodyLayout = defaultMaster.getLayout(SlideLayout.TITLE_AND_CONTENT);
    XSLFSlide slide = ppt.createSlide(titleBodyLayout);
    XSLFTextShape[] placeholders = slide.getPlaceholders();

    XSLFTextShape titleBlock = placeholders[0];
    addTitle(titleBlock, image.title);

    // Replace main content box text with supplied metadata
    XSLFTextShape descriptionBlock = placeholders[1];
    descriptionBlock.clearText();
    descriptionBlock.setTextAutofit(TextAutofit.NORMAL);

    // add creators
    if (image.creator.length > 0) {
      for(int j=0; j<image.creator.length; j++) {
        addMetadata(descriptionBlock, image.creator[j], "Creator: ");
      }
    }

    // add dates
    if (image.date.length > 0) {
      for(int j=0; j<image.date.length; j++) {
        addMetadata(descriptionBlock, image.date[j], "Date: ");
      }
    }

    // add descriptions
    if (image.description.length > 0) {
      for(int j=0; j<image.description.length; j++) {
        addMetadata(descriptionBlock, image.description[j], "Description: ");
      }
    }

    // add some text if there's no metadata present - prevents default "click here to add text" message in Office
    int totalLength = image.creator.length + image.date.length + image.description.length;
    if (totalLength == 0) {
      addMetadata(descriptionBlock, "", "No metadata supplied with image.");
    }

    resizeBlock(descriptionBlock);
  }

  private static void addImageSlide(XMLSlideShow ppt, ImageData image) throws FileNotFoundException, IOException {
    XSLFSlide slide = ppt.createSlide();
    if (image.imagePath.length() > 0) {
      byte[] pictureData = IOUtils.toByteArray(new FileInputStream(image.imagePath));
      int idx = ppt.addPicture(pictureData, XSLFPictureData.PICTURE_TYPE_PNG);
      XSLFPictureShape pic = slide.createPicture(idx);
      pic.setAnchor(new java.awt.Rectangle(image.x, image.y, image.width, image.height));
    }
  }



  private static String writePptFile(XMLSlideShow ppt, String outputFileName) {
    FileOutputStream out = null;
    try {
      out = new FileOutputStream(outputFileName);
      ppt.write(out);
    } catch(FileNotFoundException ex) {
      return ERROR + ex.getMessage();
    } catch(IOException ex) {
      return ERROR + ex.getMessage();
    } finally {
      if(out != null) {
        try {
          out.close();
        } catch(IOException ex) {
        }
      }
    }
    return outputFileName;
  }

  // Add title text to an existing slide
  private static void addTitle(XSLFTextShape block, String text ) {
    block.clearText();
    block.setTextAutofit(TextAutofit.NORMAL);
    XSLFTextParagraph header = block.addNewTextParagraph();
    header.setLevel(0);
    header.setBullet(false);
    header.setTextAlign(TextAlign.LEFT);
    XSLFTextRun t1 = header.addNewTextRun();
    t1.setText(maxText(text, 100));
    t1.setBold(true);
    t1.setFontSize(40);
    double titleHeight = block.getTextHeight();
    if (titleHeight>100) t1.setFontSize(28);   // reduce the font size if there end up being over two lines of text
  }

  // Add metadata text to a given block with the specified label
  private static void addMetadata( XSLFTextShape descriptionBlock, String text, String label ) {
    XSLFTextParagraph para = descriptionBlock.addNewTextParagraph();
    XSLFTextRun r0 = para.addNewTextRun();
    XSLFTextRun r1;

    para.setLevel(0);
    para.setBullet(false);                // 2014-11-06 turn off bullets for now
    para.setBulletFontColor(Color.BLACK); // in case we want bullets back in a future version
    para.addTabStop(108.0);

    r0.setText(label);
    r0.setFontSize(30);
    r0.setItalic(true);
    r0.setFontColor(Color.LIGHT_GRAY);

    r1 = para.addNewTextRun();
    r1.setText(text.trim());
    r1.setFontSize(30);
  }

  // Truncate a string exceeding max_length with elipses
  private static String maxText(String s, int max_length) {
    int size = s.length();
    int best_space = s.substring(0, Math.min(size,max_length)).lastIndexOf(' ');

    // just return the string if it's short enough
    if (size < max_length) { return s; }
    // otherwise, try to break on a space if there's one within the last 15 characters
    else if (best_space > max_length-15) { return s.substring(0, best_space) + "..."; }
    // or just chomp it if there's no space near the end to break on
    else { return s.substring(0, max_length) + "..."; }
  }

  // Calculate description block size and resize text as necessary to ensure all text fits within default block height - very kludgy
  private static void resizeBlock( XSLFTextShape block ) {
    double blockHeight = block.getTextHeight();

    double newHeight;
    if      (blockHeight <  340.0) newHeight = 30;
    else if (blockHeight <  550.0) newHeight = 26;
    else if (blockHeight <  900.0) newHeight = 22;
    else if (blockHeight < 1350.0) newHeight = 18;
    else if (blockHeight < 1700.0) newHeight = 14;
    else                           newHeight = 12;

    // (re)set the font size on all text runs to make overall text block fit
    List<XSLFTextParagraph> paragraphs = block.getTextParagraphs();
    for (XSLFTextParagraph p : paragraphs) {
      List<XSLFTextRun> texts = p.getTextRuns();
      for (XSLFTextRun r: texts) {
        r.setFontSize(newHeight);
      }
    }
  }

}
