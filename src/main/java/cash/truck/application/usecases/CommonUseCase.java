package cash.truck.application.usecases;

import cash.truck.domain.entities.City;
import cash.truck.domain.entities.DocumentType;
import cash.truck.domain.entities.ExpenseType;
import cash.truck.domain.entities.Gender;
import cash.truck.domain.entities.SalaryType;
import cash.truck.domain.entities.VehicleBrand;
import cash.truck.domain.repositories.CityRepository;
import cash.truck.domain.repositories.DocumentTypeRepository;
import cash.truck.domain.repositories.ExpenseTypeRepository;
import cash.truck.domain.repositories.GenderRepository;
import cash.truck.domain.repositories.SalaryTypeRepository;
import cash.truck.domain.repositories.VehicleBrandRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CommonUseCase {

    @Autowired
    private final DocumentTypeRepository documentTypeRepository;
    private final CityRepository cityRepository;
    private final GenderRepository genderRepository;
    private final ExpenseTypeRepository expenseTypeRepository;
    private final VehicleBrandRepository vehicleBrandRepository;
    private final SalaryTypeRepository salaryTypeRepository;

    public CommonUseCase(DocumentTypeRepository documentTypeRepository,
            CityRepository cityRepository,
            GenderRepository genderRepository,
            ExpenseTypeRepository expenseTypeRepository,
            VehicleBrandRepository vehicleBrandRepository,
            SalaryTypeRepository salaryTypeRepository) {
        this.documentTypeRepository = documentTypeRepository;
        this.cityRepository = cityRepository;
        this.genderRepository = genderRepository;
        this.expenseTypeRepository = expenseTypeRepository;
        this.vehicleBrandRepository = vehicleBrandRepository;
        this.salaryTypeRepository = salaryTypeRepository;
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

    public List<ExpenseType> getAllExpenseTypes() {
        return expenseTypeRepository.findAll();
    }

    public List<VehicleBrand> getAllVehicleBrands() {
        return vehicleBrandRepository.findAll();
    }

    public List<SalaryType> getAllSalaryTypes() {
        return salaryTypeRepository.findAll();
    }
}
