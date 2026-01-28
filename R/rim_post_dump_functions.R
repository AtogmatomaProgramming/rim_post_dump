# Source the check orchestration functions
# rim files:
source(file.path(getwd(), "R", "rim_check.R"))
# annual rim files:
source(file.path(getwd(), "R", "rim_check_annual.R"))
# annual rim files after NVDP match:
source(file.path(getwd(), "R", "rim_check_annual_nvdp_matched.R"))
# oab files:
source(file.path(getwd(), "R", "oab_check.R"))

# Helper and utility functions
source(file.path(getwd(), "R", "helper_functions.R"))
source(file.path(getwd(), "R", "helper_workflow_functions.R"))
source(file.path(getwd(), "R", "move_file.R"))

# Source all validation and check functions
# Functions are organized by check code (1016-1091)

# Check code 1016
source(file.path(getwd(), "R", "errors_functions", "1016_detect_false_mt1.R"))

# Check code 1017
source(file.path(getwd(), "R", "errors_functions", "1017_detect_false_mt2.R"))

# Check code 1018
source(file.path(getwd(), "R", "errors_functions", "1018_validate_mt2b_rim_stratum.R"))

# Check code 1019
source(file.path(getwd(), "R", "errors_functions", "1019_coherence_rim_stratum_gear.R"))

# Check code 1020
source(file.path(getwd(), "R", "errors_functions", "1020_coherence_rim_stratum_origin.R"))

# Check code 1021
source(file.path(getwd(), "R", "errors_functions", "1021_number_of_ships.R"))

# Check code 1022
source(file.path(getwd(), "R", "errors_functions", "1022_ships_pair_bottom_trawl.R"))

# Check code 1023
source(file.path(getwd(), "R", "errors_functions", "1023_number_of_rejections.R"))

# Check code 1024
source(file.path(getwd(), "R", "errors_functions", "1024_foreign_ships_mt2.R"))

# Check code 1025
source(file.path(getwd(), "R", "errors_functions", "1025_ships_not_in_cfpo.R"))

# Check code 1026
source(file.path(getwd(), "R", "errors_functions", "1026_ships_not_registered.R"))

# Check code 1027
source(file.path(getwd(), "R", "errors_functions", "1027_mixed_species_in_category.R"))

# Check code 1028
source(file.path(getwd(), "R", "errors_functions", "1028_not_allowed_sampled_species.R"))

# Check code 1029
source(file.path(getwd(), "R", "errors_functions", "1029_doubtful_sampled_species.R"))

# Check code 1030
source(file.path(getwd(), "R", "errors_functions", "1030_not_allowed_category_species.R"))

# Check code 1031
source(file.path(getwd(), "R", "errors_functions", "1031_doubtful_category_species.R"))

# Check code 1032
source(file.path(getwd(), "R", "errors_functions", "1032_multiple_port.R"))

# Check code 1033
source(file.path(getwd(), "R", "errors_functions", "1033_no_mixed_as_mixed.R"))

# Check code 1034
source(file.path(getwd(), "R", "errors_functions", "1034_sexes_with_same_sampled_weight.R"))

# Check code 1035
source(file.path(getwd(), "R", "errors_functions", "1035_categories_with_repeated_sexes.R"))

# Check code 1036
source(file.path(getwd(), "R", "errors_functions", "1036_all_categories_with_same_sampled_weights.R"))

# Check code 1037
source(file.path(getwd(), "R", "errors_functions", "1037_weight_sampled_zero_with_lengths_sampled.R"))

# Check code 1038
source(file.path(getwd(), "R", "errors_functions", "1038_weight_landed_zero.R"))

# Check code 1039
source(file.path(getwd(), "R", "errors_functions", "1039_weight_sampled_without_lengths_sampled.R"))

# Check code 1040
source(file.path(getwd(), "R", "errors_functions", "1040_pes_mue_desem_zero.R"))

# Check code 1041
source(file.path(getwd(), "R", "errors_functions", "1041_species_with_categories_with_same_weight_landing.R"))

# Check code 1042
source(file.path(getwd(), "R", "errors_functions", "1042_sop_zero.R"))

# Check code 1043
source(file.path(getwd(), "R", "errors_functions", "1043_sop_greater_pes_mue_vivo.R"))

# Check code 1044
source(file.path(getwd(), "R", "errors_functions", "1044_sop_greater_pes_vivo.R"))

# Check code 1045
source(file.path(getwd(), "R", "errors_functions", "1045_pes_mue_desem_greater_pes_desem.R"))

# Check code 1046
source(file.path(getwd(), "R", "errors_functions", "1046_validate_length_weight_variable.R"))

# Check code 1047
source(file.path(getwd(), "R", "errors_functions", "1047_sexed_species.R"))

# Check code 1048
source(file.path(getwd(), "R", "errors_functions", "1048_no_sexed_species.R"))

# Check code 1049
source(file.path(getwd(), "R", "errors_functions", "1049_multiple_rim_stratum.R"))

# Check code 1050
source(file.path(getwd(), "R", "errors_functions", "1050_multiple_gear.R"))

# Check code 1051
source(file.path(getwd(), "R", "errors_functions", "1051_port_mismatch_for_same_trip.R"))

# Check code 1052
source(file.path(getwd(), "R", "errors_functions", "1052_lengths_outside_size_range.R"))

# Check code 1053
source(file.path(getwd(), "R", "errors_functions", "1053_coherence_strategy_sample_type.R"))

# Check code 1054
source(file.path(getwd(), "R", "errors_functions", "1054_multiple_type_sample.R"))

# Check code 1055
source(file.path(getwd(), "R", "errors_functions", "1055_elapsed_days_exceeded.R"))

# Check code 1056
source(file.path(getwd(), "R", "errors_functions", "1056_variable_not_filled.R"))

# Check code 1057
source(file.path(getwd(), "R", "errors_functions", "1057_check_catches_p99.R"))

# Check code 1058
source(file.path(getwd(), "R", "errors_functions", "1058_taxonomic_specie_confusion.R"))

# Check code 1059
source(file.path(getwd(), "R", "errors_functions", "1059_same_trip_in_various_ports.R"))

# Check code 1060
source(file.path(getwd(), "R", "errors_functions", "1060_validate_cod_id.R"))

# Check code 1061
source(file.path(getwd(), "R", "errors_functions", "1061_multiple_ship_code.R"))

# Check code 1062
source(file.path(getwd(), "R", "errors_functions", "1062_coherence_dcf_metier_rim_stratum_origin.R"))

# Check code 1063
source(file.path(getwd(), "R", "errors_functions", "1063_coherence_dcf_fishing_ground_rim_stratum_origin.R"))

# Check code 1064
source(file.path(getwd(), "R", "errors_functions", "1064_all_categories_measured.R"))

# Check code 1065
source(file.path(getwd(), "R", "errors_functions", "1065_species_without_historical_range.R"))

# Check code 1069
source(file.path(getwd(), "R", "errors_functions", "1069_coherence_rim_mt2_prescriptions_post.R"))

# Check code 1070
source(file.path(getwd(), "R", "errors_functions", "1070_variable_with_rim_mt2_prescriptions_post.R"))

# Check code 1071
source(file.path(getwd(), "R", "errors_functions", "1071_empty_fields_in_variables.R"))

# Check code 1076
source(file.path(getwd(), "R", "errors_functions", "1076_incorrect_half_cm_measures.R"))

# Check code 1077
source(file.path(getwd(), "R", "errors_functions", "1077_g1_species_not_measured.R"))

# Check code 1078
source(file.path(getwd(), "R", "errors_functions", "1078_g2_species_not_measured.R"))

# Check code 1079
source(file.path(getwd(), "R", "errors_functions", "1079_ship_not_in_master_fishing_gear.R"))

# Check code 1080
source(file.path(getwd(), "R", "errors_functions", "1080_ship_different_fishing_gear.R"))

# Check code 1081
source(file.path(getwd(), "R", "errors_functions", "1081_ship_without_cod_sgpm.R"))

# Check code 1082
source(file.path(getwd(), "R", "errors_functions", "1082_categories_99_not_in_mt2b.R"))

# Check code 1084
source(file.path(getwd(), "R", "errors_functions", "1084_incorrect_cm_measures.R"))

# Check code 1085
source(file.path(getwd(), "R", "errors_functions", "1085_trip_is_checked.R"))

# Check code 1087
source(file.path(getwd(), "R", "errors_functions", "1087_more_than_two_ships.R"))

# Check code 1088
source(file.path(getwd(), "R", "errors_functions", "1088_new_species_sampled.R"))

# Check code 1089
source(file.path(getwd(), "R", "errors_functions", "1089_foreign_ships_mt1.R"))

# Check code 1090
source(file.path(getwd(), "R", "errors_functions", "1090_mixed_as_no_mixed.R"))

# Check code 1091
source(file.path(getwd(), "R", "errors_functions", "1091_sampling_is_checked.R"))

# Check code 1092
source(file.path(getwd(), "R", "errors_functions", "1092_variable_not_in_master.R"))

# Check code 1093
source(file.path(getwd(), "R", "errors_functions", "1093_coherence_fishing_modality_rim_stratum.R"))