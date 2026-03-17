package cash.truck.infrastructure.controllers;

import cash.truck.application.usecases.*;
import cash.truck.application.utility.Constants;
import cash.truck.application.utility.ResponseMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import cash.truck.application.utility.ResponseErrorMessage;
import org.springframework.web.multipart.MultipartFile;

import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Iterator;
import javax.imageio.IIOImage;
import javax.imageio.ImageIO;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.stream.ImageOutputStream;
import java.awt.image.BufferedImage;

@RestController
@RequestMapping(value = "/common", produces = MediaType.APPLICATION_JSON_VALUE)
@CrossOrigin(origins = { "http://localhost:9000", "http://168.231.93.145/", "http://truck.ccsoluciones.com.co/",
        "https://truck.ccsoluciones.com.co/" })
public class CommonController {

    @Autowired
    private CommonUseCase commonUseCase;

    @GetMapping("/getDocumentTypes")
    public ResponseEntity<Object> getAllDocuments() {
        ResponseMessage responseMessage = new ResponseMessage(commonUseCase.getAllDocumentTypes(),
                HttpStatus.OK.value(),
                HttpStatus.OK.name(), null, Constants.DOCUMENT_TYPES_SEARCH_OK);
        return new ResponseEntity<>(responseMessage, HttpStatus.OK);
    }

    @GetMapping("/getGenders")
    public ResponseEntity<Object> getAllGenders() {
        ResponseMessage responseMessage = new ResponseMessage(commonUseCase.getAllGenders(), HttpStatus.OK.value(),
                HttpStatus.OK.name(), null, Constants.GENDERS_SEARCH_OK);
        return new ResponseEntity<>(responseMessage, HttpStatus.OK);
    }

    @GetMapping("/getCities")
    public ResponseEntity<Object> getCities() {
        ResponseMessage responseMessage = new ResponseMessage(commonUseCase.getAllCities(), HttpStatus.OK.value(),
                HttpStatus.OK.name(), null, Constants.CITIES_SEARCH_OK);
        return new ResponseEntity<>(responseMessage, HttpStatus.OK);
    }

    @GetMapping("/getExpenseTypes")
    public ResponseEntity<Object> getExpenseTypes() {
        ResponseMessage responseMessage = new ResponseMessage(commonUseCase.getAllExpenseTypes(), HttpStatus.OK.value(),
                HttpStatus.OK.name(), null, Constants.EXPENSE_TYPES_SEARCH_OK);
        return new ResponseEntity<>(responseMessage, HttpStatus.OK);
    }

    @GetMapping("/getVehicleBrands")
    public ResponseEntity<Object> getVehicleBrands() {
        ResponseMessage responseMessage = new ResponseMessage(commonUseCase.getAllVehicleBrands(),
                HttpStatus.OK.value(),
                HttpStatus.OK.name(), null, Constants.VEHICLE_BRANDS_SEARCH_OK);
        return new ResponseEntity<>(responseMessage, HttpStatus.OK);
    }

    @GetMapping("/getSalaryTypes")
    public ResponseEntity<Object> getSalaryTypes() {
        ResponseMessage responseMessage = new ResponseMessage(commonUseCase.getAllSalaryTypes(),
                HttpStatus.OK.value(),
                HttpStatus.OK.name(), null, Constants.SALARY_TYPES_SEARCH_OK);
        return new ResponseEntity<>(responseMessage, HttpStatus.OK);
    }

    @PostMapping(value = "/upload-photo", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Object> uploadPhoto(
            @RequestParam("type") String type,
            @RequestParam("id") Long id,
            @RequestParam("photo") MultipartFile photo) {
        ImageIO.scanForPlugins();
        try {
            String subDir;
            switch (type.toLowerCase()) {
                case "owner":
                    subDir = "owner";
                    break;
                case "driver":
                    subDir = "driver";
                    break;
                case "vehicle":
                    subDir = "vehicle";
                    break;
                default:
                    ResponseErrorMessage badRequest = new ResponseErrorMessage(
                            HttpStatus.BAD_REQUEST.value(),
                            "Invalid type. Must be owner, driver or vehicle",
                            Constants.PHOTO_UPLOAD_KO);
                    return new ResponseEntity<>(badRequest, HttpStatus.BAD_REQUEST);
            }

            BufferedImage image = ImageIO.read(photo.getInputStream());
            if (image == null) {
                ResponseErrorMessage badRequest = new ResponseErrorMessage(
                        HttpStatus.BAD_REQUEST.value(),
                        "Invalid image file",
                        Constants.PHOTO_UPLOAD_KO);
                return new ResponseEntity<>(badRequest, HttpStatus.BAD_REQUEST);
            }

            String fileName = "photo" + id + ".webp";
            String dirPath = "/var/www/html/truck/images/" + subDir;
            Path targetDir = Paths.get(dirPath);
            Files.createDirectories(targetDir);
            Path targetFile = targetDir.resolve(fileName);

            Iterator<ImageWriter> writers = ImageIO.getImageWritersByFormatName("webp");
            if (!writers.hasNext()) {
                StringBuilder formats = new StringBuilder();
                for (String format : ImageIO.getWriterFormatNames()) {
                    formats.append(format).append(", ");
                }
                throw new IOException("WebP writer not found. Available writer formats: " + formats.toString() + 
                                     ". Make sure dependencies are correctly loaded and the app is restarted.");
            }
            ImageWriter writer = writers.next();
            try (ImageOutputStream ios = ImageIO.createImageOutputStream(new FileOutputStream(targetFile.toFile()))) {
                writer.setOutput(ios);
                ImageWriteParam param = writer.getDefaultWriteParam();
                if (param.canWriteCompressed()) {
                    param.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
                    param.setCompressionType(param.getCompressionTypes()[0]);
                    param.setCompressionQuality(0.75f);
                }
                writer.write(null, new IIOImage(image, null, null), param);
            } finally {
                writer.dispose();
            }

            String url = "https://truck.ccsoluciones.com.co/truck/images/" + subDir + "/" + fileName;
            ResponseMessage responseMessage = new ResponseMessage(url,
                    HttpStatus.OK.value(),
                    HttpStatus.OK.name(), null, Constants.PHOTO_UPLOAD_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.OK);
        } catch (IOException e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(
                    HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    e.getMessage(), Constants.PHOTO_UPLOAD_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

}
