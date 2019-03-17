import Dialog, { DialogActions, DialogContent, DialogContentText, DialogTitle, } from 'material-ui/Dialog';

import Button from 'material-ui/Button';
import DateFormatInput from 'material-ui-next-datepicker';
import { FormControl } from 'material-ui/Form';
import { MenuItem } from 'material-ui/Menu';
import PropTypes from 'prop-types';
import React from 'react';
import Select from 'material-ui/Select';
import axios from 'axios';
import { withStyles } from 'material-ui/styles';

var config = require('./config.json');

const hostUrl = config.url + config.service_path;
const DOC_STATUS = {
    All: 'All',
    0: 'Not Started',
    1: 'Draft Received',
    2: 'No Draft',
    3: 'In Progress',
    4: 'Issues Pending',
    5: 'Completed',
    6: 'No Impact'
};

const styles = theme => ({
    root: {
        display: 'flex',
        flexWrap: 'wrap',
    },
    formControl: {
        margin: theme.spacing.unit,
        minWidth: 210,
    },
    selectEmpty: {
        marginTop: theme.spacing.unit * 2,
    },
    button: {
        margin: theme.spacing.unit,
    },
    input: {
        display: 'none',
    },
});

class MilestoneMenuBar extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            error: null,
            //isLoadedProduct: false,
            //isLoadedVersion:false,
            isLoadedPrs: false,
            products: [],
            selectedProduct: '',
            productVersions: [],
            selectedVersion: '',
            pullRequests: [],
            selectedDayFrom: undefined,
            selectedDayTo: undefined,
            mapNumToStatus: null,
            dialogOpen: false,
            milestones: [],
            selectedMilestone: '',
            selectedStatus: ''
        };
        this.onSubmit = this.onSubmit.bind(this);
        this.handleOk = this.handleOk.bind(this);
        this.onStatusChanged = this.onStatusChanged.bind(this);
        this.loadProducts = this.loadProducts.bind(this);
    }

    handleClickOpen = () => {
        this.setState({ dialogOpen: true });
        this.loadMilestones();
    };

    handleClose = () => {
        this.setState({ dialogOpen: false });
    };

    handleProductChange = event => {
        this.setState({ selectedProduct: event.target.value, selectedStatus: DOC_STATUS.All });
        this.loadVersions(event.target.value);
    };

    handleStatusChange = event => {
        this.setState({ selectedStatus: event.target.value });
    };

    handleVersionChange = event => {
        this.setState({ selectedVersion: event.target.value, selectedStatus: DOC_STATUS.All });
    };

    onFromDateChange = (date) => {
        date.setHours(5, 30, 0, 0);
        this.setState({ selectedDayFrom: date })
    };

    onToDateChange = (date) => {
        date.setHours(5, 30, 0, 0);
        this.setState({ selectedDayTo: date })
    };

    getQueryVariable = (variable) => {
        var query = window.location.search.substring(1);
        var vars = query.split('&');
        for (var i = 0; i < vars.length; i++) {
            var pair = vars[i].split('=');
            if (decodeURIComponent(pair[0]) == variable) {
                return decodeURIComponent(pair[1]);
            }
        }
        //console.log('Query variable %s not found', variable);
    };

    componentDidMount() {
        this.generateDates();
        this.loadProducts();

        // If query params exist
        if (window.location.search.indexOf("?") != -1) {
                this.setState({
                    selectedProduct: this.getQueryVariable("product"),
                    selectedVersion: this.getQueryVariable("version"),
                    selectedStatus: this.getQueryVariable("status"),
                    selectedDayFrom: new Date(this.getQueryVariable("start")),
                    selectedDayTo: new Date(this.getQueryVariable("end"))
                }, this.onSubmit);
        }
    }

    loadProducts() {
        axios.get(hostUrl + '/products')
            .then(response => {
                if (response.hasOwnProperty("data")) {
                    let selectedProduct =this.getQueryVariable("product") ||response.data.data[0];
                    this.setState({
                        //isLoadedProduct: true,
                        products: response.data.data,
                        selectedProduct
                    },this.loadVersions(selectedProduct));
                }
            })
            .catch(error => {
                this.setState({
                    //isLoadedProduct: true,
                    error: error,
                });
            });
    }

    checkVersion = (value,arr) => {
        let status = false;
        for(let i=0; i<arr.length; i++){
            let name = arr[i];
            if(name == value){
              status = true;
              break;
            }
        }
        return status;
    }

    loadVersions(product) {
        if (product === '') {
            this.setState({
                //isLoadedVersion: false,
                productVersions: [],
                selectedVersion: '',
                selectedStatus: ''
            });
        }
        axios.get(hostUrl + '/versions?product=' + product)
            .then(response => {
                if (response.hasOwnProperty("data")) {
                    response.data.data.splice(0, 0, 'All');
                    let selectedVersion = this.getQueryVariable("version") || response.data.data[0];
                    let selectedStatus = this.state.selectedStatus || DOC_STATUS.All;
                    if(!this.checkVersion(selectedVersion,response.data.data)){
                        selectedVersion = response.data.data[0];
                    }
                    this.setState({
                        //isLoadedVersion: true,
                        productVersions: response.data.data,
                        selectedVersion,
                        selectedStatus
                    });
                }
            })
            .catch(error => {
                this.setState({
                    //isLoadedVersion: true,
                    productVersions: [],
                    selectedVersion: null,
                    selectedStatus: null,
                    error: error,
                });
            });
    }

    onSubmit() {
        var info = {
            product: this.state.selectedProduct,
            version: this.state.selectedVersion,
            dateFrom: this.state.selectedDayFrom,
            dateTo: this.state.selectedDayTo,
            docStatus: this.state.selectedStatus
        };
        this.props.onSubmit(info);
    }

    loadMilestones() {
        var url = hostUrl + '/milestones';
        url = encodeURI(url);
        axios.get(url)
            .then(response => {
                if (response.data) {
                    this.setState({ milestones: response.data.data });
                }
            })
            .catch(error => {
                alert(error);
            });
    }

    generateDates() {
        var now = new Date();
        var month = now.getMonth();
        var quarter = month / 3;

        // console.log(now.getFullYear());
        var startDate, endDate;
        if (quarter < 1) {
            startDate = new Date(now.getFullYear(), 0, 1);
            endDate = new Date(now.getFullYear(), 2, 31)
        } else if (quarter < 2) {
            startDate = new Date(now.getFullYear(), 3, 1);
            endDate = new Date(now.getFullYear(), 5, 30)
        } else if (quarter < 3) {
            startDate = new Date(now.getFullYear(), 6, 1);
            endDate = new Date(now.getFullYear(), 8, 30)
        } else {
            startDate = new Date(now.getFullYear(), 9, 1);
            endDate = new Date(now.getFullYear(), 11, 31)
        }

        this.setState({
            selectedDayFrom: startDate,
            selectedDayTo: endDate
        });
    }

    handleOk() {
        if (this.state.selectedMilestone > 0) {
            for (var i in this.state.milestones) {
                var milestone = this.state.milestones[i];
                if (milestone.milestoneId === this.state.selectedMilestone) {
                    this.setState({
                        selectedProduct: milestone.productName,
                        selectedVersion: milestone.ver,
                        selectedDayFrom: new Date(milestone.startDate.time),
                        selectedDayTo: new Date(milestone.endDate.time),
                        dialogOpen: false,
                    });
                    return;
                }
            }


        }
        this.setState({ dialogOpen: false });
    }

    onStatusChanged(e) {
        console.log("value: " + e.target.value);
        this.setState({ selectedMilestone: e.target.value });
    }


    render() {
        const { classes } = this.props;
        const fromDate = this.state.selectedDayFrom;
        const toDate = this.state.selectedDayTo;

        //        alert("render called");
        //        alert(JSON.stringify(this.state));

        // if (this.state.error) {
        //     return <div>Error: {this.state.error.message}</div>;
        // } else if (!this.state.isLoadedProduct || !this.state.isLoadedVersion) {
        //     return <div>Loading...</div>;
        // } else {
        return (
            <div>
                <form className={classes.root} autoComplete="off">
                    <FormControl className={classes.formControl}>
                        <b>Product: </b>
                        <Select
                            value={this.state.selectedProduct}
                            onChange={this.handleProductChange}
                        >
                            {this.state.products.map(product => (
                                <MenuItem key={product} value={product}>
                                    {product}
                                </MenuItem>
                            ))}
                        </Select>
                    </FormControl>

                    <FormControl className={classes.formControl}>
                        <b>Version: </b>
                        <Select
                            disabled={(this.state.selectedProduct == '')}
                            value={this.state.selectedVersion}
                            onChange={this.handleVersionChange}
                        >
                            {this.state.productVersions.map(version => (
                                <MenuItem key={version} value={version}>
                                    {version}
                                </MenuItem>
                            ))}
                        </Select>
                    </FormControl>

                    {/* Filter by doc-status */}
                    <FormControl className={classes.formControl}>
                        <b>Doc Status: </b>
                        <Select
                            disabled={(this.state.selectedProduct == '' || this.state.selectedVersion == '')}
                            value={this.state.selectedStatus}
                            onChange={this.handleStatusChange}
                        >
                            {Object.keys(DOC_STATUS).map(version => (
                                <MenuItem value={version}>
                                    {DOC_STATUS[version]}
                                </MenuItem>
                            ))}
                        </Select>
                    </FormControl>

                    <FormControl className={classes.formControl}>
                        <b>Date from: </b>
                        <DateFormatInput name='date-input' value={fromDate} onChange={this.onFromDateChange} />
                    </FormControl>
                    <FormControl className={classes.formControl}>
                        <b>To: </b>
                        <DateFormatInput name='date-input' value={toDate} onChange={this.onToDateChange} />
                    </FormControl>
                    <Button
                        variant="raised"
                        className={classes.button}
                        disabled={this.state.selectedDayFrom === undefined ||
                            this.state.selectedDayTo === undefined ||
                            this.state.selectedVersion === '' ||
                            this.state.selectedStatus === ''}
                        onClick={this.onSubmit}
                    >
                        {this.props.buttonText}
                    </Button>

                    {/*<Button*/}
                    {/*variant="raised"*/}
                    {/*className={classes.button}*/}
                    {/*// disabled={this.state.selectedDayFrom === undefined ||*/}
                    {/*// this.state.selectedDayTo === undefined ||*/}
                    {/*// this.state.selectedVersion === 'None'}*/}
                    {/*onClick={this.handleClickOpen}*/}
                    {/*>*/}
                    {/*Load Milestone*/}
                    {/*</Button>*/}

                    <Dialog
                        open={this.state.dialogOpen}
                        onClose={this.handleClose}
                        aria-labelledby="alert-dialog-title"
                        aria-describedby="alert-dialog-description"
                    >
                        <DialogTitle id="alert-dialog-title">{"Load Milestone"}</DialogTitle>
                        <DialogContent>
                            <DialogContentText id="alert-dialog-description">
                                Select a milestone from below.
                            </DialogContentText>
                            <form>
                                <FormControl className={classes.formControl}>
                                    <Select
                                        value={this.state.selectedMilestone}
                                        onChange={this.onStatusChanged}
                                    >
                                        <MenuItem value="">
                                            <em>None</em>
                                        </MenuItem>
                                        {this.state.milestones.map(d => (
                                            <MenuItem key={d.milestoneId} value={d.milestoneId}>
                                                {d.milestoneName}
                                            </MenuItem>
                                        ))}
                                    </Select>
                                </FormControl>
                            </form>
                        </DialogContent>
                        <DialogActions>
                            <Button onClick={this.handleClose} color="primary">
                                Cancel
                            </Button>
                            <Button onClick={this.handleOk} color="primary" autoFocus>
                                Ok
                            </Button>
                        </DialogActions>
                    </Dialog>

                </form>
            </div>
        );
    }

    // }
}

MilestoneMenuBar.propTypes = {
    classes: PropTypes.object.isRequired,
};

export default withStyles(styles)(MilestoneMenuBar);