package cash.truck.application.usecases;

import cash.truck.domain.entities.City;
import cash.truck.domain.entities.DocumentType;
import cash.truck.domain.entities.Expires;
import cash.truck.domain.entities.Gender;
import cash.truck.domain.repositories.CityRepository;
import cash.truck.domain.repositories.DocumentTypeRepository;
import cash.truck.domain.repositories.ExpiresRepository;
import cash.truck.domain.repositories.GenderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CommonUseCase {

    @Autowired
    private final DocumentTypeRepository documentTypeRepository;
    private final CityRepository cityRepository;
    private final GenderRepository genderRepository;
    private final ExpiresRepository expiresRepository;

    public CommonUseCase(DocumentTypeRepository documentTypeRepository,
                         CityRepository cityRepository,
                         GenderRepository genderRepository,
                         ExpiresRepository expiresRepository){
        this.documentTypeRepository = documentTypeRepository;
        this.cityRepository = cityRepository;
        this.genderRepository = genderRepository;
        this.expiresRepository = expiresRepository;
    }

    public List<DocumentType> getAllDocumentTypes() {
        return documentTypeRepository.findAll();
    }

    public List<City> getAllCities() {
        return cityRepository.findAll();
    }

    public List<Gender> getAllGenders() {
        return genderRepository.findAll();
    }

    public List<Expires> getAllExpires() {
        return expiresRepository.findAll();
    }
}
