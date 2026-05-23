import numpy as np
import matplotlib.pyplot as plt

def simulate_chsh_exact_lab_setup():
    # --- Visualization Setup ---
    plt.rcParams.update({
        'font.family': 'serif',
        'font.serif': ['Times New Roman', 'DejaVu Serif'],
        'font.size': 12,
        'axes.labelsize': 14,
        'axes.titlesize': 14,
        'xtick.labelsize': 12,
        'ytick.labelsize': 12,
        'legend.fontsize': 11,
        'axes.linewidth': 1.2,
        'xtick.major.width': 1.2,
        'ytick.major.width': 1.2,
        'xtick.direction': 'in',
        'ytick.direction': 'in',
        'xtick.minor.visible': True,
        'ytick.minor.visible': True,
        'xtick.top': True,
        'ytick.right': True,
    })

    # --- CHSH Measurement Angles (in radians) ---
    # Alice's measurement bases
    a       = np.radians(0)
    a_perp  = np.radians(90)
    a_prime = np.radians(45)
    ap_perp = np.radians(-45)
    
    # Bob's measurement bases
    b       = np.radians(22.5)
    b_perp  = np.radians(112.5)
    b_prime = np.radians(67.5)
    bp_perp = np.radians(-22.5)
    
    # --- Physical Simulation Parameters ---
    N_pulses = 20
    # Classical pseudo-random source polarization (H or V)
    source_pol = np.random.choice([0, np.pi/2], size=N_pulses)
    noise_level = 0.01  # Natural Gaussian noise simulating intensity fluctuations
    
    thresholds = np.linspace(0.01, 0.99, 150)
    S_values = []
    
    # --- Helper Functions for Coincidences & Correlation ---
    def get_coincidences(alpha, beta, th):
        # Ideal intensity derived from Malus's law
        I_A_ideal = np.cos(alpha - source_pol)**2
        I_B_ideal = np.cos(beta - source_pol)**2
        
        # Introduce natural noise representing physical lab fluctuations
        I_A = I_A_ideal + np.random.normal(0, noise_level, size=N_pulses)
        I_B = I_B_ideal + np.random.normal(0, noise_level, size=N_pulses)
        
        # Digitization: Register a "click" if intensity exceeds the threshold
        clicks_A = I_A >= th
        clicks_B = I_B >= th
        
        return np.sum(clicks_A & clicks_B)
        
    def calc_E(alpha, alpha_p, beta, beta_p, th):
        # Extract coincidence counts for the 4 projections of the given basis pair
        N_pp = get_coincidences(alpha, beta, th)
        N_mm = get_coincidences(alpha_p, beta_p, th)
        N_pm = get_coincidences(alpha, beta_p, th)
        N_mp = get_coincidences(alpha_p, beta, th)
        
        total = N_pp + N_mm + N_pm + N_mp
        if total == 0:
            return 0
        
        # Calculate the correlation coefficient E
        return (N_pp + N_mm - N_pm - N_mp) / total

    # --- Perform Threshold Sweep ---
    for th in thresholds:
        E_ab   = calc_E(a, a_perp, b, b_perp, th)
        E_abp  = calc_E(a, a_perp, b_prime, bp_perp, th)
        E_apb  = calc_E(a_prime, ap_perp, b, b_perp, th)
        E_apbp = calc_E(a_prime, ap_perp, b_prime, bp_perp, th)
        
        # Calculate standard CHSH parameter S
        S = E_ab - E_abp + E_apb + E_apbp
        S_values.append(S)
        
    # --- Results Extraction ---
    max_S = max(S_values)
    best_th_max = thresholds[np.argmax(S_values)]
    
    print(f"\n--- Lab Setup Simulation Results ---")
    print(f"Maximum S achieved: {max_S:.3f} at Threshold = {best_th_max:.3f}")
    if max_S > 2:
        print("Success! The classical discrete source violated the Bell inequality via post-selection.\n")
    else:
        print("No violation achieved with the current parameters.\n")
    
    # --- Plotting ---
    plt.figure(figsize=(8, 5)) 
    
    S_array = np.array(S_values)
    
    # Highlight regions where the classical bound is violated
    plt.fill_between(thresholds, 0, 5, where=(S_array > 2), color='gray', alpha=0.2, interpolate=True)
    
    plt.plot(thresholds, S_values, color='#003366', linewidth=2.5, label='Simulated S Parameter')
    
    plt.axhline(2, color='#CC0000', linestyle='--', linewidth=1.5, label='Classical Bound (S=2)')
    plt.axhline(2.828, color='#008000', linestyle='-.', linewidth=1.5, label=r'Quantum Bound (S=$2\sqrt{2}$)')
    
    plt.xlabel('Detection Intensity Threshold')
    plt.ylabel('CHSH Parameter ($S$)')
    
    plt.xlim(0, 1)
    plt.ylim(0, 3.7)
    
    plt.legend(loc='upper right', frameon=True)
    
    plt.tight_layout()
    plt.savefig('CHSH_Simulation_Result.pdf', format='pdf', bbox_inches='tight')
    plt.show()

if __name__ == "__main__":
    simulate_chsh_exact_lab_setup()