rim_check <- function(samples_imported) {
  tryCatch({
    # filter by sample type
    sample_types <- c(1, 2, 4, 6)

    samples_imported <- lapply(samples_imported, function(x) {
      out <- x[x[["COD_TIPO_MUE"]] %in% sample_types, ]
      return(out)
    })

    catches <- samples_imported$catches
    catches_in_lengths <- samples_imported$catches_in_lengths
    lengths_sampled <- samples_imported$lengths

    err <- list()

    # ---- REPEATED IN IPDTOSIRENO ----

    err$estrato_rim <- variable_not_in_master(catches, "ESTRATO_RIM")

    err$puerto <- variable_not_in_master(catches, "COD_PUERTO")

    err$arte <- variable_not_in_master(catches, "COD_ARTE")

    err$origen <- variable_not_in_master(catches, "COD_ORIGEN")

    err$procedencia <- variable_not_in_master(catches, "PROCEDENCIA")

    err$tipo_muestreo <- variable_not_in_master(catches, "COD_TIPO_MUE")

    err$false_MT1 <- detect_false_mt1(catches, lengths_sampled)

    err$false_MT2 <- detect_false_mt2(catches, lengths_sampled)

    err$no_mixed_as_mixed <- no_mixed_as_mixed(lengths_sampled)

    err$mixed_as_no_mixed <- mixed_as_no_mixed(catches)

    # err$estrato_rim_prescriptions <- variable_with_rim_mt2_prescriptions_post(catches, "ESTRATO_RIM")
    # err$puerto_prescriptions <- variable_with_rim_mt2_prescriptions_post(catches, "COD_PUERTO")
    # err$origen_prescriptions <- variable_with_rim_mt2_prescriptions_post(catches, "COD_ORIGEN")
    # err$arte_prescriptions <- variable_with_rim_mt2_prescriptions_post(catches, "COD_ARTE")
    # err$metier_dcf_prescriptions <- variable_with_rim_mt2_prescriptions_post(catches, "METIER_DCF")
    # err$caladero_dcf_prescriptions <- variable_with_rim_mt2_prescriptions_post(catches, "CALADERO_DCF")

    err$empty_fields_in_variables_catches <- empty_fields_in_variables(
      catches,
      "RIM_CATCHES"
    )
    err$empty_fields_in_variables_lengths <- empty_fields_in_variables(
      lengths_sampled,
      "RIM_LENGTHS"
    )

    # ---- IN HEADER ----

    # TODO: I think this check must be deleted
    err$errors_mt2b_rim_stratum <- validate_mt2b_rim_stratum(catches)

    err$coherence_estrato_rim_gear <- coherence_rim_stratum_gear(catches, "RIM")

    err$coherence_estrato_rim_origin <- coherence_rim_stratum_origin(
      catches,
      "RIM"
    )

    # err$coherence_rim_mt2_prescriptions <- coherence_rim_mt2_prescriptions_post(catches)

    err$no_ships <- number_of_ships(catches)
    
    err$more_than_two_ships <- more_than_two_ships(catches)

    err$number_of_rejections <- number_of_rejections(catches)

    err$errors_countries_mt1 <- foreign_ships_mt1(catches)

    err$errors_countries_mt2 <- foreign_ships_mt2(catches)

    err$multiple_ship_code <- multiple_ship_code(catches)

    ##### TO DO: ADD CHECKING SHIPS WITH SIRENO FILES

    err$errors_ships_not_in_cfpo <- ships_not_in_cfpo(catches)

    # no_en_cfpo <- err$errors_ships_not_in_cfpo %>%
    #   filter(!grepl("^8\\d{5}",COD_BARCO) & COD_BARCO != 0) %>%
    #   select(COD_BARCO, BARCO, COD_PUERTO, PUERTO)%>%
    #   unique()

    err$errors_ships_not_registered <- ships_not_registered(catches)

    err$errors_multiple_estrato_rim <- multiple_rim_stratum(catches)

    err$errors_multiple_arte <- multiple_gear(catches)

    err$errors_multiple_puerto <- port_mismatch_for_same_trip(catches)

    err$errors_num_barcos_pareja <- ships_pair_bottom_trawl(catches)

    err$estrategia <- coherence_strategy_sample_type(catches)

    err$multiple_tipo_muestreo <- multiple_type_sample(catches)

    err$tiempo_transcurrido <- elapsed_days_exceeded(catches)

    err$check_same_trip_in_various_ports <- same_trip_in_various_ports(catches)

    err$checkSampleInCharge <- variable_not_filled(
      catches,
      "RESPONSABLE_MUESTREO"
    )

    err$ship_without_cod_sgpm <- ship_without_cod_sgpm(catches)

    err$coherence_fishing_modality_rim_stratum <- coherence_fishing_modality_rim_stratum(catches)

    # This errors must be used only in anual, when the Fishing Ground and DCF
    # Metier is filled:
    # err$coherence_dcf_fishing_ground_rim_stratum_origin <- coherence_dcf_fishing_ground_rim_stratum_origin(catches)
    # err$coherence_dcf_metier_rim_stratum_origin <- coherence_dcf_metier_rim_stratum_origin(catches)

    # ---- IN SPECIES ----

    err$mixed_species_category <- mixed_species_in_category(catches_in_lengths)

    err$not_allowed_sampled_species <- not_allowed_sampled_species(catches)

    err$sampled_species_doubtful <- doubtful_sampled_species(catches)

    err$not_allowed_category_species <- not_allowed_category_species(
      catches_in_lengths
    )

    err$doubtful_category_species <- doubtful_category_species(catches_in_lengths)

    err$sexes_with_same_sampled_weight <- sexes_with_same_sampled_weight(
      catches_in_lengths
    )

    err$categories_with_repeated_sexes <- categories_with_repeated_sexes(
      catches_in_lengths
    )

    err$lenghts_weights_sample <- validate_length_weight_variable(catches)

    err$no_sexed_species <- no_sexed_species(lengths_sampled)

    err$sexed_species <- sexed_species(lengths_sampled)

    err$taxonomic_specie_confusion <- taxonomic_specie_confusion(
      catches,
      catches_in_lengths
    )
    
    err$new_species_sampled <- new_species_sampled(catches_in_lengths)

    # TODO: FIND A BETTER WAY TO CHECK THIS, WHICH ADD THE SPECIES NAME
    # err$a3CodeFilled <- variable_not_filled(catches, "A3_ESP_MUE")

    # ---- IN WEIGHTS ----

    err$same_sampled_weight <- all_categories_with_same_sampled_weights(
      catches_in_lengths
    )

    err$sampled_weight_zero <- weight_sampled_zero_with_lengths_sampled(
      catches_in_lengths
    )

    err$weight_landed_zero <- weight_landed_zero(catches)

    err$weight_sampled_without_length_sampled <- weight_sampled_without_lengths_sampled(
      catches_in_lengths
    )

    err$pes_mue_desem_zero <- pes_mue_desem_zero(catches_in_lengths)

    err$especies_con_categorias_igual_peso_desembarcado <- species_with_categories_with_same_weight_landing(
      catches
    )

    err$sop_zero <- sop_zero(catches_in_lengths)

    err$sop_greater_pes_mue_vivo <- sop_greater_pes_mue_vivo(catches_in_lengths)

    err$sop_mayor_peso_vivo <- sop_greater_pes_vivo(catches_in_lengths)

    err$pes_mue_desem_mayor_pes_desem <- pes_mue_desem_greater_pes_desem(
      catches_in_lengths
    )

    # TODO: FIND A BETTER WAY TO CHECK THIS, WHICH ADD THE SPECIES NAME
    # err$a3CodeFilled <- variable_not_filled(catches_in_lengths, "A3_ESP_CAT")

    err$categories_99_not_in_mt2b <- categories_99_not_in_mt2b(catches)

    # comment in annual:
    err$capturas_percentil_99 <- check_catches_p99(catches)

    # ---- IN LENGTHS ----
    err$all_categories_measured <- all_categories_measured(
      catches,
      lengths_sampled
    )

    err$check_cm_measures <- incorrect_cm_measures(lengths_sampled)

    err$check_half_cm_measures <- incorrect_half_cm_measures(lengths_sampled)

    # uncomment in annual checks
    # err$unchecked_sampligs <- getUncheckedSamplings(lengths_sampled)

    # comment in annual:
    err$with_historical_size_range <- species_without_historical_range(lengths_sampled)

    # comment in annual:
    err$size_range <- lengths_outside_size_range(lengths_sampled)
    err$g1_species_not_measured <- g1_species_not_measured(catches, lengths_sampled)
    err$g2_species_not_measured <- g2_species_not_measured(catches, lengths_sampled)

    # ---- COD_ID ----
    # This check is useful in the annual review. When the data is dumped in
    # SIRENO, COD_ID is automatically filled. But, if later someone add a new
    # sample, the COD_ID doesn't fill and is saved as empty.
    err$cod_id_filled_catches <- validate_cod_id(catches)
    err$cod_id_filled_catches_in_lengths <- validate_cod_id(catches_in_lengths)
    err$cod_id_filled_lengths <- validate_cod_id(lengths_sampled)

    # ---- COMBINE ERRORS ----

    # separated by influence area
    combined_errors <- format_errors_list(errors_list = err, separate_by_ia = T)

    return(combined_errors)
  })
}
