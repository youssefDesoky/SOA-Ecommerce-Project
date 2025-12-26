(function () {
    var cartEmpty = document.body.getAttribute('data-cart-empty') === 'true';
    if (cartEmpty) return;

    var step1 = document.getElementById('step-1');
    var step2 = document.getElementById('step-2');
    var step1Indicator = document.getElementById('step-1-indicator');
    var step2Indicator = document.getElementById('step-2-indicator');

    var nextStep1Btn = document.getElementById('next-step-1');
    var prevStep2Btn = document.getElementById('prev-step-2');

    var paymentLabels = document.querySelectorAll('.payment-method');
    var paymentRadios = document.querySelectorAll('input[name="payment_method"]');
    var cardDetails = document.getElementById('cardDetails');

    var cardNumber = document.getElementById('cardNumber');
    var cardName = document.getElementById('cardName');
    var cardExpiry = document.getElementById('cardExpiry');
    var cardCvv = document.getElementById('cardCvv');

    var terms = document.getElementById('terms');
    var termsError = document.getElementById('termsError');
    var loadingOverlay = document.getElementById('loadingOverlay');

    function showStep(n) {
        if (n === 1) {
            step1.classList.add('active');
            step2.classList.remove('active');
            step1Indicator.classList.add('active');
            step1Indicator.classList.remove('completed');
            step2Indicator.classList.remove('active');
        } else {
            step1.classList.remove('active');
            step2.classList.add('active');
            step1Indicator.classList.remove('active');
            step1Indicator.classList.add('completed');
            step2Indicator.classList.add('active');
        }
    }

    function validateStep1OrFocus() {
        var ids = ['firstName','lastName','email','phone','government','city','address'];
        for (var i = 0; i < ids.length; i++) {
            var el = document.getElementById(ids[i]);
            if (el && !el.checkValidity()) {
                el.reportValidity();
                return false;
            }
        }
        return true;
    }

    function setCardRequired(required) {
        cardNumber.required = required;
        cardName.required = required;
        cardExpiry.required = required;
        cardCvv.required = required;
    }

    function setPaymentUI(method) {
        for (var i = 0; i < paymentLabels.length; i++) {
            paymentLabels[i].classList.remove('selected');
        }

        var selector = 'input[name="payment_method"][value="' + method + '"]';
        var chosen = document.querySelector(selector);
        if (chosen && chosen.closest) {
            var label = chosen.closest('.payment-method');
            if (label) label.classList.add('selected');
        }

        if (method === 'credit_card') {
            cardDetails.classList.add('show');
            setCardRequired(true);
        } else {
            cardDetails.classList.remove('show');
            setCardRequired(false);
        }
    }

    nextStep1Btn.addEventListener('click', function () {
        if (!validateStep1OrFocus()) return;
        showStep(2);
    });

    prevStep2Btn.addEventListener('click', function () {
        showStep(1);
    });

    for (var i = 0; i < paymentRadios.length; i++) {
        paymentRadios[i].addEventListener('change', function (e) {
            setPaymentUI(e.target.value);
        });
    }
    setPaymentUI('cash_on_delivery');

    cardNumber.addEventListener('input', function (e) {
        var raw = e.target.value.replace(/\D/g, '').slice(0, 16);
        e.target.value = raw.replace(/(.{4})/g, '$1 ').trim();
    });
    cardExpiry.addEventListener('input', function (e) {
        var raw = e.target.value.replace(/\D/g, '').slice(0, 4);
        e.target.value = (raw.length >= 3) ? (raw.slice(0,2) + '/' + raw.slice(2)) : raw;
    });
    cardCvv.addEventListener('input', function (e) {
        e.target.value = e.target.value.replace(/\D/g, '').slice(0, 4);
    });

    document.getElementById('checkoutForm').addEventListener('submit', function (e) {
        if (!validateStep1OrFocus()) {
            showStep(1);
            e.preventDefault();
            return;
        }

        if (!terms.checked) {
            termsError.classList.add('show');
            showStep(2);
            e.preventDefault();
            return;
        } else {
            termsError.classList.remove('show');
        }

        loadingOverlay.classList.add('active');
    });

    terms.addEventListener('change', function () {
        if (terms.checked) termsError.classList.remove('show');
    });
})();