
add_library(License
    FWDCertVerifier.cc
    FWDCertVerifier.h
    FWDLicenseManager.cc
    FWDLicenseManager.h
    LicenseMasterKeys.h
)

target_link_libraries(License
    PUBLIC
        qgc
        OpenSSL::SSL
        OpenSSL::Crypto
)

target_include_directories(License INTERFACE ${CMAKE_CURRENT_SOURCE_DIR})
